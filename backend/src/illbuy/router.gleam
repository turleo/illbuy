import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list
import gleam/option
import illbuy/types.{type Context}
import illbuy/users/endpoint as users_endpoint
import illbuy/users/service
import illbuy/websocket/endpoint as websocket_endpoint
import mist.{type Connection, type ResponseData}
import pog

pub fn handle_request(ctx: Context) {
  fn(req: Request(Connection)) -> Response(ResponseData) {
    case request.path_segments(req) {
      ["Users", ..] -> users_endpoint.handle_request(ctx, req)
      ["ws"] ->
        websocket_endpoint.handle_request |> authorization_required(ctx, req)
      ["ping"] -> ping(req, ctx)
      _ -> not_found()
    }
    |> response.set_header("Access-Control-Allow-Origin", "*")
  }
}

fn ping(_, context: Context) -> Response(ResponseData) {
  let _ = pog.query("select 1;") |> pog.execute(context.db)
  response.new(200)
  |> response.set_body(mist.Bytes(bytes_tree.from_string("pong")))
}

fn not_found() -> Response(ResponseData) {
  response.new(404)
  |> response.set_header("Content-Type", "text/plain; charset=utf-8")
  |> response.set_body(mist.Bytes(bytes_tree.from_string("🤷‍♀️ nothing here")))
}

fn authorization_required(
  callback,
  ctx: Context,
  req: Request(Connection),
) -> Response(ResponseData) {
  case list.key_find(req.headers, "Authorization") {
    Ok(token) ->
      case service.verify_jwt(ctx, token) {
        Ok(token) -> callback(ctx, req, token)
        _ ->
          response.new(401) |> response.set_body(mist.Bytes(bytes_tree.new()))
      }
    _ -> authorization_required_url(callback, ctx, req)
  }
}

fn authorization_required_url(
  callback,
  ctx: Context,
  req: Request(Connection),
) -> Response(ResponseData) {
  case req.query {
    option.Some(token) ->
      case service.verify_jwt(ctx, token) {
        Ok(token) -> callback(ctx, req, token)
        _ ->
          response.new(401) |> response.set_body(mist.Bytes(bytes_tree.new()))
      }
    _ -> response.new(401) |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}
