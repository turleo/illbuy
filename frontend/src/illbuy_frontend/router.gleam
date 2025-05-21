import gleam/uri.{type Uri}
import illbuy_frontend/types
import illbuy_frontend/views/auth
import illbuy_frontend/views/error
import illbuy_frontend/views/home
import lustre/element

pub fn route(model: types.Model) -> element.Element(types.Msg) {
  case model.route {
    types.Home -> home.view()
    types.Login -> auth.view(types.Login, model)
    types.Register -> auth.view(types.Register, model)
    types.NotFound -> error.view()
  }
}

pub fn parse_route(uri: Uri) -> types.Route {
  case uri.path_segments(uri.path) {
    [""] -> types.Home
    ["login"] -> types.Login
    ["register"] -> types.Register
    _ -> types.NotFound
  }
}

pub fn on_url_change(uri: Uri) -> types.Msg {
  types.RouteChanged(parse_route(uri))
}
