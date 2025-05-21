import gleam/bit_array
import gleam/bytes_tree
import illbuy/types.{type Context}
import illbuy/users/repo
import illbuy_shared/pb/users as pb
import wisp.{type Request, type Response}

pub fn route(req: Request, ctx: Context) -> Response {
  use body <- wisp.require_bit_array_body(req)
  case wisp.path_segments(req) {
    [_, "Authenticate"] -> {
      let auth = pb.AuthenticateRequest("", "")
      let answer = case pb.decode_to_authenticate_request(body, auth) {
        Ok(r) -> repo.login(ctx, r.email, r.password)
        _ -> Error(pb.Unknown)
      }
      encode_response(answer)
    }
    [_, "RegisterUser"] -> {
      let auth = pb.AuthenticateRequest("", "")
      let answer = case pb.decode_to_authenticate_request(body, auth) {
        Ok(r) -> repo.register(ctx, r.email, r.password)
        _ -> Error(pb.Unknown)
      }
      encode_response(answer)
    }
    [_, "RefreshToken"] -> {
      let auth = pb.RefreshTokenRequest("")
      let answer = case pb.decode_to_refresh_token_request(body, auth) {
        Ok(r) -> repo.refresh_token(ctx, r)
        _ -> Error(pb.Unknown)
      }
      encode_response(answer)
    }
    _ -> wisp.not_found()
  }
}

fn encode_response(answer: Result(pb.TokenMessage, pb.Errors)) {
  case answer {
    Ok(message) -> {
      wisp.response(200)
      |> wisp.set_body(
        pb.encode_token_message(message)
        |> bytes_tree.from_bit_array
        |> wisp.Bytes,
      )
    }
    Error(error) ->
      wisp.response(400)
      |> wisp.set_body(
        pb.encode_errors(error)
        |> bytes_tree.from_bit_array
        |> wisp.Bytes,
      )
  }
}
