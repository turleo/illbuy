import gleam/erlang/process
import illbuy/router
import illbuy/web
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let context = web.create_context()

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request(_, context), context.env.secret)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
  process.sleep_forever()
}
