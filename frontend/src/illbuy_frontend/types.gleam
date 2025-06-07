import gleam/option
import illbuy_shared/pb/users
import lustre_websocket as ws

pub type Route {
  NotFound
  Home
  Login
  Register
}

pub type AuthState {
  LoggedIn(token: users.TokenMessage)
  LoggedOut(loading: Bool, error: option.Option(users.Errors))
}

pub type Model {
  Model(auth: AuthState, route: Route)
}

pub type Msg {
  NothingHappened
  RouteChanged(Route)
  LoginFormSubmitted(route: Route, request: users.AuthenticateRequest)
  LoginRefreshAuth
  BackendLoginFeedback(response: AuthState)
  WsWrapper(ws.WebSocketEvent)
}
