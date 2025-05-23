import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import illbuy/types.{type Context}
import illbuy/users/endpoint as users_endpoint
import mist.{type Connection, type ResponseData}
import pog

pub fn handle_request(ctx: Context) {
  fn(req: Request(Connection)) -> Response(ResponseData) {
    case request.path_segments(req) {
      ["Users", ..] -> users_endpoint.handle_request(ctx, req)
      ["ping"] -> ping(req, ctx)
      _ -> ping(req, ctx)
    }
  }
}

fn ping(_, context: Context) -> Response(ResponseData) {
  let _ = pog.query("select 1;") |> pog.execute(context.db)
  response.new(200)
  |> response.set_body(mist.Bytes(bytes_tree.from_string("pong")))
}
