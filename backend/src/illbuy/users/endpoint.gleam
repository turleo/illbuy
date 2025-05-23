import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import illbuy/types.{type Context}
import illbuy/users/repo
import illbuy_shared/pb/users as pb
import mist.{type Connection, type ResponseData}

pub fn handle_request(ctx: Context, req: Request(Connection)) {
  let body = mist.read_body(req, 1024 * 1024 * 10)
  case body {
    Ok(body) -> parse_request(ctx, req, body.body)
    _ -> todo
  }
}

pub fn parse_request(ctx: Context, req: Request(Connection), body: BitArray) {
  case request.path_segments(req) {
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
    _ -> encode_error(pb.Unknown)
  }
}

fn encode_response(answer: Result(pb.TokenMessage, pb.Errors)) {
  case answer {
    Ok(message) -> {
      response.new(200)
      |> response.set_body(
        pb.encode_token_message(message)
        |> bytes_tree.from_bit_array
        |> mist.Bytes,
      )
    }
    Error(error) -> encode_error(error)
  }
}

fn encode_error(error: pb.Errors) {
  response.new(400)
  |> response.set_body(
    mist.Bytes(bytes_tree.from_bit_array(pb.encode_errors(error))),
  )
}
