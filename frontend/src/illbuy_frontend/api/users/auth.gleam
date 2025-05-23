import gleam/bit_array
import gleam/fetch
import gleam/float
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/javascript/promise
import gleam/option
import gleam/order
import gleam/time/timestamp
import gleam/uri
import illbuy_frontend/types
import illbuy_shared/pb/users
import lustre/effect.{type Effect}
import plinth/javascript/storage

pub fn auth(
  endpoint: types.Route,
  data: users.AuthenticateRequest,
) -> Effect(types.Msg) {
  let endpoint = case endpoint {
    types.Login -> "Authenticate"
    types.Register -> "RegisterUser"
    _ -> ""
  }
  // TODO: base url
  let assert Ok(u) = uri.parse("http://localhost:8000/Users/" <> endpoint)
  let assert Ok(req) = request.from_uri(u)
  let req =
    req
    |> request.set_method(http.Post)
    |> request.set_body(users.encode_authenticate_request(data))

  effect.from(fn(dispatch) {
    fetch.send_bits(req)
    |> promise.try_await(fetch.read_bytes_body)
    |> promise.tap(parse_response(dispatch))
    Nil
  })
}

pub fn refresh_token(data: users.RefreshTokenRequest) -> Effect(types.Msg) {
  // TODO: base url
  let assert Ok(u) = uri.parse("http://localhost:8000/Users/RefreshToken")
  let assert Ok(req) = request.from_uri(u)
  let req =
    req
    |> request.set_method(http.Post)
    |> request.set_body(users.encode_refresh_token_request(data))

  effect.from(fn(dispatch) {
    fetch.send_bits(req)
    |> promise.try_await(fetch.read_bytes_body)
    |> promise.tap(parse_response(dispatch))
    Nil
  })
}

fn parse_response(dispatch) {
  fn(resp: Result(response.Response(BitArray), fetch.FetchError)) {
    case resp {
      Ok(resp) ->
        parse_ok_response(resp.body)
        |> types.BackendLoginFeedback
        |> dispatch
      _ ->
        types.LoggedOut(False, option.Some(users.Unknown))
        |> types.BackendLoginFeedback
        |> dispatch
    }
  }
}

fn parse_ok_response(resp: BitArray) {
  let message = users.TokenMessage("", "", 0)
  case users.decode_to_token_message(resp, message) {
    Ok(message) -> {
      save_token(resp)
      message
      |> types.LoggedIn
    }
    _ -> {
      let error = case users.decode_to_errors(resp) {
        Ok(error) -> error
        _ -> users.Unknown
      }
      types.LoggedOut(False, option.Some(error))
    }
  }
}

fn save_token(token: BitArray) {
  let assert Ok(storage) = storage.local()
  let _ =
    storage.set_item(storage, "auth", bit_array.base64_encode(token, False))
  Nil
}

pub fn load_local_auth() {
  let assert Ok(storage) = storage.local()
  case storage.get_item(storage, "auth") {
    Ok(token_base64) -> {
      case bit_array.base64_decode(token_base64) {
        Ok(token) -> parse_ok_response(token)
        _ -> types.LoggedOut(False, option.None)
      }
    }
    _ -> types.LoggedOut(False, option.None)
  }
}

pub fn check_if_expired(token: users.TokenMessage) -> Effect(types.Msg) {
  let now =
    timestamp.system_time()
    |> timestamp.to_unix_seconds()
    |> float.truncate
  case int.compare(now, token.refresh_after) {
    order.Gt ->
      token.refresh_token |> users.RefreshTokenRequest |> refresh_token
    _ -> effect.none()
  }
}
