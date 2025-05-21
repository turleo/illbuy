import gleam/list
import gleam/option
import gleam/string
import illbuy/types.{type Context}
import illbuy/users/service
import illbuy/users/types as users_types
import illbuy_shared/pb/users as pb
import logging
import pog

pub fn login(ctx: Context, email: String, password: String) {
  case
    pog.query("SELECT id, password FROM users.users WHERE email = $1")
    |> pog.parameter(pog.text(email))
    |> pog.returning(users_types.id_password(email, password))
    |> pog.execute(ctx.db)
  {
    Ok(response) -> login_by_row(ctx, list.first(response.rows))
    Error(e) -> {
      logging.log(logging.Info, string.inspect(e))
      Error(pb.InvalidCredentials)
    }
  }
}

fn login_by_row(
  ctx: Context,
  user: Result(users_types.User, Nil),
) -> Result(pb.TokenMessage, pb.Errors) {
  case user {
    Ok(user) -> service.login(ctx, user)
    _ -> Error(pb.InvalidCredentials)
  }
}

pub fn register(ctx: Context, email: String, password: String) {
  case service.register(ctx, email, password) {
    Ok(user) -> insert_new_user(ctx, user)
    _ -> Error(pb.ConstraintFailed)
  }
}

fn insert_new_user(
  ctx: Context,
  user: users_types.User,
) -> Result(pb.TokenMessage, pb.Errors) {
  case
    pog.query(
      "INSERT INTO users.users (id, email, password)
      VALUES (xid.generate($1), $2, $3)
      RETURNING id",
    )
    |> pog.parameter(pog.int(1))
    |> pog.parameter(pog.text(option.unwrap(user.email, "")))
    |> pog.parameter(pog.text(option.unwrap(user.hashed_password, "")))
    |> pog.returning(users_types.decode_id())
    |> pog.execute(ctx.db)
  {
    Ok(returned) -> {
      let assert Ok(user_id) = list.first(returned.rows)
      Ok(service.generate_refresh_access_tokens(
        ctx,
        users_types.User(..user, id: option.Some(user_id)),
      ))
    }
    Error(_) -> Error(pb.UserAlreadyExist)
  }
}

pub fn refresh_token(ctx: Context, token: pb.RefreshTokenRequest) {
  case service.refresh_token(ctx, token.refresh_token) {
    option.Some(token) -> Ok(token)
    _ -> Error(pb.TokenExpired)
  }
}
