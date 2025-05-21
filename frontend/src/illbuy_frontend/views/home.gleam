import lustre/attribute
import lustre/element
import lustre/element/html
import plinth/browser/window

pub fn view() {
  window.self() |> window.set_location("https://github.com/turleo/illbuy")
  html.a([attribute.href("https://github.com/turleo/illbuy")], [
    element.text("Check out source on GitHub!"),
  ])
}
