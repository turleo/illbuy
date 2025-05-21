import lustre/attribute
import lustre/element
import lustre/element/html

pub fn field(
  title: String,
  id: String,
  type_: String,
  autocomplete: String,
  hint: String,
) {
  html.div([attribute.class("w-full grid")], [
    html.label([attribute.for(id)], [element.text(title)]),
    html.input([
      attribute.class("input validator"),
      attribute.id(id),
      attribute.name(id),
      attribute.type_(type_),
      attribute.autocomplete(autocomplete),
      attribute.placeholder(hint),
      attribute.required(True),
    ]),
  ])
}
