import gleam/bytes_tree
import illbuy/types.{type Context}
import illbuy/users/endpoint as users_endpoint
import illbuy/web
import pog
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["Users", ..] -> users_endpoint.route(req, ctx)
    ["ping"] -> ping(req, ctx)
    _ -> wisp.not_found()
  }
}

fn ping(_: Request, context: Context) -> Response {
  let _ = pog.query("select 1;") |> pog.execute(context.db)
  wisp.log_debug("ping")
  wisp.response(200)
  |> wisp.set_body(wisp.Bytes(bytes_tree.from_string("pong")))
}
