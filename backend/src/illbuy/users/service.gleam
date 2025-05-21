import argus
import gleam/float
import gleam/int
import gleam/option
import gleam/order
import gleam/regexp
import gleam/string
import gleam/time/duration
import gleam/time/timestamp
import gwt
import illbuy/types.{type Context}
import illbuy/users/types as users_types
import illbuy_shared/pb/users as pb
import logging

pub fn register(
  ctx: Context,
  email: String,
  password: String,
) -> Result(users_types.User, pb.Errors) {
  let assert Ok(email_re) = regexp.from_string(".+@.+\\..+")
  let assert Ok(password_re) = regexp.from_string(ctx.env.password_validator)
  let user =
    users_types.User(
      id: option.None,
      email: option.Some(email),
      password: option.Some(password),
      hashed_password: option.None,
    )
  case regexp.check(email_re, email), regexp.check(password_re, password) {
    True, True -> Ok(generate_password_hash(ctx, user))
    _, _ -> Error(pb.ConstraintFailed)
  }
}

pub fn login(
  ctx: Context,
  user: users_types.User,
) -> Result(pb.TokenMessage, pb.Errors) {
  case check_password(user) {
    True -> Ok(generate_refresh_access_tokens(ctx, user))
    _ -> Error(pb.InvalidCredentials)
  }
}

pub fn refresh_token(
  ctx: Context,
  token: String,
) -> option.Option(pb.TokenMessage) {
  case verify_jwt(ctx, token) {
    Ok(token) -> {
      case token.audience == users_types.Refresh {
        True ->
          generate_refresh_access_tokens(ctx, user_from_token(token))
          |> option.Some
        _ -> option.None
      }
    }
    e -> {
      logging.log(logging.Info, string.inspect(e))
      option.None
    }
  }
}

pub fn check_access_token(
  ctx: Context,
  token: String,
) -> option.Option(users_types.User) {
  case verify_jwt(ctx, token) {
    Ok(token) -> {
      case token.audience == users_types.Access {
        True -> option.Some(user_from_token(token))
        _ -> option.None
      }
    }
    e -> {
      logging.log(logging.Info, string.inspect(e))
      option.None
    }
  }
}

pub fn user_from_token(token: users_types.Token) -> users_types.User {
  users_types.User(
    id: option.Some(token.subject),
    email: option.None,
    password: option.None,
    hashed_password: option.None,
  )
}

pub fn generate_password_hash(
  ctx: Context,
  user: users_types.User,
) -> users_types.User {
  let assert option.Some(password) = user.password
  case argus.hasher() |> argus.hash(password, ctx.env.secret) {
    Ok(hash) ->
      users_types.User(..user, hashed_password: option.Some(hash.encoded_hash))
    Error(e) -> panic as string.inspect(e)
  }
}

pub fn check_password(user: users_types.User) -> Bool {
  case
    argus.verify(
      option.unwrap(user.hashed_password, ""),
      option.unwrap(user.password, ""),
    )
  {
    Ok(answer) -> answer
    Error(_) -> False
  }
}

pub fn generate_refresh_access_tokens(
  ctx: Context,
  user: users_types.User,
) -> pb.TokenMessage {
  let now = timestamp.system_time()
  let assert option.Some(user_id) = user.id
  let refresh_after =
    timestamp.add(now, duration.hours(1))
    |> timestamp.to_unix_seconds
    |> float.truncate
  let access_jwt =
    users_types.Token(
      subject: user_id,
      audience: users_types.Access,
      expiration: refresh_after,
    )

  let refiresh_jwt =
    users_types.Token(
      subject: user_id,
      audience: users_types.Refresh,
      expiration: timestamp.add(now, duration.hours(720))
        // 24 * 30
        |> timestamp.to_unix_seconds
        |> float.truncate,
    )
  pb.TokenMessage(
    access_token: generate_new_jwt(ctx, access_jwt),
    refresh_token: generate_new_jwt(ctx, refiresh_jwt),
    refresh_after: refresh_after,
  )
}

pub fn generate_new_jwt(ctx: Context, jwt: users_types.Token) {
  gwt.new()
  |> gwt.set_subject(int.to_base36(jwt.subject))
  |> gwt.set_audience(users_types.token_audience_to_string(jwt.audience))
  |> gwt.set_expiration(jwt.expiration)
  |> gwt.to_signed_string(gwt.HS256, ctx.env.secret)
}

pub fn verify_jwt(
  ctx: Context,
  jwt: String,
) -> Result(users_types.Token, option.Option(gwt.JwtDecodeError)) {
  case gwt.from_signed_string(jwt, ctx.env.secret) {
    Ok(decoded) -> decode_verified_jwt(decoded)
    Error(e) -> Error(option.Some(e))
  }
}

pub fn decode_verified_jwt(
  decoded: gwt.Jwt(gwt.Verified),
) -> Result(users_types.Token, option.Option(gwt.JwtDecodeError)) {
  case
    gwt.get_audience(decoded),
    gwt.get_expiration(decoded),
    gwt.get_subject(decoded)
  {
    Ok(audience), Ok(expiration), Ok(subject) ->
      check_decoded_jwt(audience, expiration, subject)
    _, _, _ -> Error(option.None)
  }
}

pub fn check_decoded_jwt(
  audience: String,
  expiration: Int,
  subject: String,
) -> Result(users_types.Token, option.Option(gwt.JwtDecodeError)) {
  let decoded_audience = users_types.string_to_token_audience(audience)
  let decoded_subject = int.base_parse(subject, 36)
  let compared_expiration =
    timestamp.compare(
      timestamp.system_time(),
      timestamp.from_unix_seconds(expiration),
    )
  case decoded_audience, compared_expiration, decoded_subject {
    Ok(audience), order.Lt, Ok(subject) ->
      Ok(users_types.Token(subject, audience, expiration))
    _, _, _ -> Error(option.None)
  }
}
