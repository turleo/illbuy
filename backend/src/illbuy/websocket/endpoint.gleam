import gleam/erlang/process
import gleam/function
import gleam/http/request.{type Request}
import gleam/option
import gleam/otp/actor
import gleam/string
import illbuy/types.{type Context}
import illbuy/users/types.{type Token} as users_types
import illbuy/websocket/kv_actor
import mist.{type Connection}

type State {
  State(
    ctx: Context,
    subject: process.Subject(String),
    user: option.Option(Int),
    workspace: option.Option(Int),
    item_list: option.Option(Int),
  )
}

pub fn handle_request(ctx: Context, req: Request(Connection), token: Token) {
  mist.websocket(
    request: req,
    on_init: fn(_conn) {
      let subject = process.new_subject()
      let selector =
        echo process.new_selector()
          |> process.selecting(subject, function.identity)

      process.send(ctx.kv_actors.users, kv_actor.Join(token.subject, subject))

      #(
        State(
          ctx,
          subject,
          option.Some(token.subject),
          option.None,
          option.None,
        ),
        option.Some(selector),
      )
    },
    on_close: fn(state) {
      case state.user {
        option.Some(user) ->
          process.send(ctx.kv_actors.users, kv_actor.Leave(user, state.subject))
        _ -> Nil
      }
      case state.workspace {
        option.Some(id) ->
          process.send(
            ctx.kv_actors.workspaces,
            kv_actor.Leave(id, state.subject),
          )
        _ -> Nil
      }
      case state.item_list {
        option.Some(id) ->
          process.send(ctx.kv_actors.lists, kv_actor.Leave(id, state.subject))
        _ -> Nil
      }
    },
    handler: handle_ws_message,
  )
}

pub type MyMessage {
  String
}

fn handle_ws_message(state: State, conn, message) {
  case message {
    mist.Text("ping") -> {
      let assert Ok(_) = mist.send_text_frame(conn, "pong")
      process.send(
        state.ctx.kv_actors.users,
        kv_actor.Broadcast(1, string.inspect(process.self()) <> " pinged"),
      )
      actor.continue(state)
    }
    mist.Text(_) | mist.Binary(_) -> {
      actor.continue(state)
    }
    mist.Custom(text) -> {
      echo text
      let assert Ok(_) = mist.send_text_frame(conn, text)
      actor.continue(state)
    }
    mist.Closed | mist.Shutdown -> actor.Stop(process.Normal)
  }
}
