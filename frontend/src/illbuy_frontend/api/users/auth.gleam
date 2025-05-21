import gleam/fetch
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/option
import gleam/uri
import illbuy_frontend/types
import illbuy_shared/pb/users
import lustre/effect.{type Effect}

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
      Ok(resp) -> parse_ok_response(resp, dispatch)
      _ ->
        types.LoggedOut(False, option.Some(users.Unknown))
        |> types.BackendLoginFeedback
        |> dispatch
    }
  }
}

fn parse_ok_response(resp: response.Response(BitArray), dispatch) {
  let message = users.TokenMessage("", "", 0)
  case users.decode_to_token_message(resp.body, message) {
    Ok(message) ->
      message
      |> types.LoggedIn
      |> types.BackendLoginFeedback
      |> dispatch
    _ -> {
      let error = case users.decode_to_errors(resp.body) {
        Ok(error) -> error
        _ -> users.Unknown
      }
      types.LoggedOut(False, option.Some(error))
      |> types.BackendLoginFeedback
      |> dispatch
    }
  }
}
