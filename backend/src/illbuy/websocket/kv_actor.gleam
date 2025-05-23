import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/list
import gleam/otp/actor
import gleam/string
import logging

pub type Message {
  Shutdown

  Join(key: Int, value: Subject(String))
  Leave(key: Int, value: Subject(String))
  Rejoin(from: Int, to: Int, value: Subject(String))

  Broadcast(key: Int, message: String)
}

type State =
  dict.Dict(Int, List(Subject(String)))

pub fn handle_message(
  message: Message,
  state: State,
) -> actor.Next(Message, State) {
  case message {
    Shutdown -> actor.Stop(process.Normal)

    Join(key, value) -> {
      join_handler(state, key, value)
      |> actor.continue()
    }

    Leave(key, value) -> {
      leave_handler(state, key, value)
      |> actor.continue()
    }

    Rejoin(from, to, value) -> {
      leave_handler(state, from, value)
      |> join_handler(to, value)
      |> actor.continue()
    }

    Broadcast(key, message) -> {
      logging.log(
        logging.Info,
        "sending "
          <> message
          <> " to "
          <> int.to_string(key)
          <> ": "
          <> string.inspect(dict.get(state, key)),
      )
      case dict.get(state, key) {
        Ok(l) -> send_message_to_list(l, message)
        _ -> Nil
      }

      actor.continue(state)
    }
  }
}

fn join_handler(state: State, to: Int, value: Subject(String)) {
  let list_value = case dict.get(state, to) {
    Ok(l) -> {
      [value, ..l]
    }
    _ -> [value]
  }
  dict.insert(state, to, list_value)
}

fn leave_handler(state: State, from: Int, value: Subject(String)) {
  let list_value = case dict.get(state, from) {
    Ok(l) -> {
      list.filter(l, fn(v) { v != value })
    }
    _ -> []
  }
  dict.insert(state, from, list_value)
}

fn send_message_to_list(to: List(Subject(String)), message: String) {
  case to {
    [current, ..rest] -> {
      process.send(current, message)
      send_message_to_list(rest, message)
    }
    _ -> Nil
  }
}
