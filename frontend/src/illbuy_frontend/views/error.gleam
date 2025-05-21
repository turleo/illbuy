import lustre/element
import lustre/element/html

pub fn view() {
  html.div([], [
    html.p([], [element.text("🥺")]),
    html.p([], [element.text("Sorry, nothing here")]),
  ])
}
