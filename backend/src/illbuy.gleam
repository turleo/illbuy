import gleam/erlang/process
import illbuy/router
import illbuy/web
import logging
import mist

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  let context = web.create_context()

  let assert Ok(_) =
    mist.new(router.handle_request(context))
    |> mist.port(8000)
    |> mist.start_http
  process.sleep_forever()
}
