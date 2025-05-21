import formal/form
import gleam/option
import gleam/string
import illbuy_frontend/components/input_field
import illbuy_frontend/types
import illbuy_shared/pb/users
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

fn show_error(error: users.Errors) {
  html.p([attribute.role("alert"), attribute.class("alert alert-error")], [
    element.text(case error {
      users.InvalidCredentials -> "🤨 Something wrong with your credentials"
      users.UserAlreadyExist -> "🤔 We think that we know this email"
      users.ConstraintFailed -> "😭 Please check your inputs"
      _ -> "😢 Something wrong"
    }),
  ])
}

pub fn view(opened: types.Route, model: types.Model) {
  html.form(
    [
      attribute.class("flex flex-col gap-4"),
      event.on_submit(fn(form_data) {
        let result =
          form.decoding({
            use email <- form.parameter
            use password <- form.parameter
            users.AuthenticateRequest(email: email, password: password)
          })
          |> form.with_values(form_data)
          |> form.field(
            "email",
            form.string
              |> form.and(form.must_not_be_empty)
              |> form.and(form.must_be_an_email),
          )
          |> form.field(
            "password",
            form.string
              |> form.and(form.must_not_be_empty),
          )
          |> form.finish

        case result {
          Ok(data) -> {
            types.LoginFormSubmitted(opened, data)
          }
          Error(form_state) -> {
            let _ =
              panic as string.append(
                "Value is not valid (this is strange, how about browser validation): ",
                string.inspect(form_state),
              )
          }
        }
      }),
    ],
    [
      case model.auth {
        types.LoggedOut(_, option.Some(error)) -> show_error(error)
        _ -> html.div([], [])
      },
      input_field.field("Email", "email", "email", "email", "email@domain.tld"),
      input_field.field(
        "Password",
        "password",
        "password",
        case opened {
          types.Login -> "current-password"
          _ -> "current-password"
        },
        "dot dot dot dot",
      ),
      html.input([
        attribute.class("btn btn-primary"),
        attribute.type_("submit"),
        attribute.value(case opened {
          types.Login -> "Log in!"
          _ -> "Register!"
        }),
      ]),
      case opened {
        types.Login ->
          html.a([attribute.href("/register")], [
            html.text("Okay, but how can i register?"),
          ])
        _ ->
          html.a([attribute.href("/login")], [
            html.text("Okay, but what if i already registered?"),
          ])
      },
    ],
  )
}
