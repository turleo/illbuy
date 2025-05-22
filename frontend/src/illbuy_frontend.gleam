import gleam/option
import illbuy_frontend/api/users/auth
import illbuy_frontend/router
import illbuy_frontend/types
import lustre
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import modem

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn init(_) -> #(types.Model, Effect(types.Msg)) {
  let assert Ok(input_uri) = modem.initial_uri()

  #(
    types.Model(auth.load_local_auth(), router.parse_route(input_uri)),
    modem.init(router.on_url_change),
  )
}

fn update(
  model: types.Model,
  msg: types.Msg,
) -> #(types.Model, Effect(types.Msg)) {
  case msg {
    types.RouteChanged(route) -> #(
      types.Model(..model, route: route),
      effect.none(),
    )
    types.LoginFormSubmitted(register, data) -> {
      #(model, auth.auth(register, data))
    }
    types.BackendLoginFeedback(auth_state) -> #(
      types.Model(..model, auth: auth_state),
      effect.none(),
    )
    types.NothingHappened -> #(model, effect.none())
  }
}

fn view(model: types.Model) -> element.Element(types.Msg) {
  html.div([], [router.route(model)])
}
