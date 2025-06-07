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
  let saved_auth = auth.load_local_auth()
  let expired_token_effect = case saved_auth {
    types.LoggedIn(token) -> auth.check_if_expired(token)
    _ -> effect.none()
  }
  #(
    types.Model(saved_auth, router.parse_route(input_uri)),
    effect.batch([
      modem.init(router.on_url_change),
      // ws.init(
      //   "http://localhost:8000/ws?token="
      //     <> types.LoggedIn(saved_auth).token.access_token,
      //   types.WsWrapper,
      // ),
      expired_token_effect,
    ]),
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
    types.LoginRefreshAuth -> {
      case model.auth {
        types.LoggedIn(auth) -> #(model, auth.check_if_expired(auth))
        _ -> #(model, effect.none())
      }
    }
    types.WsWrapper(a) -> {
      echo a
      #(model, effect.none())
    }

    types.NothingHappened -> #(model, effect.none())
  }
}

fn view(model: types.Model) -> element.Element(types.Msg) {
  html.div([], [router.route(model)])
}
