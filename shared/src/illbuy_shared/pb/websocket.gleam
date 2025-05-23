import acrostic/decoding.{type FieldDecoder, FieldDecoder}
import acrostic/encoding.{type FieldEncoder, FieldEncoder}
import acrostic/wire
import gleam/bit_array
import gleam/int
import gleam/list
import gleam/result

pub type Domain {
  DomainUnknown
  DomainUser
  DomainWorkspace
  DomainList
}

pub const empty_domain = DomainUnknown

pub fn encode_domain(domain: Domain) -> BitArray {
  case domain {
    DomainUnknown -> encoding.encode_varint(0)
    DomainUser -> encoding.encode_varint(1)
    DomainWorkspace -> encoding.encode_varint(2)
    DomainList -> encoding.encode_varint(3)
  }
}

fn decode_to_domain(binary: BitArray) -> Result(Domain, String) {
  case decoding.to_varint(binary, 0) {
    0 -> Ok(DomainUnknown)
    1 -> Ok(DomainUser)
    2 -> Ok(DomainWorkspace)
    3 -> Ok(DomainList)
    _ ->
      Error(
        "Decode to domain failed: " <> bit_array.base64_encode(binary, False),
      )
  }
}

pub const domain_field_encoder = FieldEncoder(wire.VarInt, encode_domain)

fn domain_field_decoder() {
  FieldDecoder(wire.VarInt, decode_to_domain)
}

pub type Action {
  AcitonUnknown
  ActionUnsubscribe
  ActionSubscribe
  ActionCreate
  ActionUpdate
  ActionDelete
}

pub const empty_action = AcitonUnknown

pub fn encode_action(action: Action) -> BitArray {
  case action {
    AcitonUnknown -> encoding.encode_varint(0)
    ActionUnsubscribe -> encoding.encode_varint(1)
    ActionSubscribe -> encoding.encode_varint(2)
    ActionCreate -> encoding.encode_varint(3)
    ActionUpdate -> encoding.encode_varint(4)
    ActionDelete -> encoding.encode_varint(5)
  }
}

fn decode_to_action(binary: BitArray) -> Result(Action, String) {
  case decoding.to_varint(binary, 0) {
    0 -> Ok(AcitonUnknown)
    1 -> Ok(ActionUnsubscribe)
    2 -> Ok(ActionSubscribe)
    3 -> Ok(ActionCreate)
    4 -> Ok(ActionUpdate)
    5 -> Ok(ActionDelete)
    _ ->
      Error(
        "Decode to action failed: " <> bit_array.base64_encode(binary, False),
      )
  }
}

pub const action_field_encoder = FieldEncoder(wire.VarInt, encode_action)

fn action_field_decoder() {
  FieldDecoder(wire.VarInt, decode_to_action)
}

// struct start -----------------------------------
pub type Item {
  Item(id: Int, checked: Bool, name: String)
}

pub const empty_item = Item(0, False, "")

pub fn encode_item(item: Item) -> BitArray {
  <<>>
  |> bit_array.append(encoding.encode_field(
    1,
    item.id,
    encoding.int_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    2,
    item.checked,
    encoding.bool_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    3,
    item.name,
    encoding.string_field_encoder,
  ))
}

pub fn decode_to_item(binary: BitArray, item: Item) -> Result(Item, String) {
  case binary {
    <<>> -> Ok(item)
    _ -> {
      use #(key, binary) <- result.try(decoding.read_key(binary))
      case key.field_number {
        1 -> {
          use #(id, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.int_field_decoder,
          ))
          decode_to_item(binary, Item(..item, id: id))
        }
        2 -> {
          use #(checked, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.bool_field_decoder,
          ))
          decode_to_item(binary, Item(..item, checked: checked))
        }
        3 -> {
          use #(name, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_item(binary, Item(..item, name: name))
        }
        _ -> Error("Invalid field_number")
      }
    }
  }
}

pub const item_field_encoder = FieldEncoder(wire.Len, encode_item)

fn item_field_decoder() {
  FieldDecoder(wire.Len, decode_to_item(_, empty_item))
}

pub type ItemList {
  ItemList(id: Int, name: String)
}

pub const empty_item_list = ItemList(0, "")

pub fn encode_item_list(item_list: ItemList) -> BitArray {
  <<>>
  |> bit_array.append(encoding.encode_field(
    1,
    item_list.id,
    encoding.int_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    2,
    item_list.name,
    encoding.string_field_encoder,
  ))
}

pub fn decode_to_item_list(
  binary: BitArray,
  item_list: ItemList,
) -> Result(ItemList, String) {
  case binary {
    <<>> -> Ok(item_list)
    _ -> {
      use #(key, binary) <- result.try(decoding.read_key(binary))
      case key.field_number {
        1 -> {
          use #(id, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.int_field_decoder,
          ))
          decode_to_item_list(binary, ItemList(..item_list, id: id))
        }
        2 -> {
          use #(name, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_item_list(binary, ItemList(..item_list, name: name))
        }
        _ -> Error("Invalid field_number")
      }
    }
  }
}

pub const item_list_field_encoder = FieldEncoder(wire.Len, encode_item_list)

fn item_list_field_decoder() {
  FieldDecoder(wire.Len, decode_to_item_list(_, empty_item_list))
}

pub type Workspace {
  Workspace(id: Int, name: String, users: List(User))
}

pub const empty_workspace = Workspace(0, "", [])

pub fn encode_workspace(workspace: Workspace) -> BitArray {
  <<>>
  |> bit_array.append(encoding.encode_field(
    1,
    workspace.id,
    encoding.int_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    2,
    workspace.name,
    encoding.string_field_encoder,
  ))
  |> bit_array.append(encoding.encode_repeated_field(
    3,
    workspace.users,
    user_field_encoder,
  ))
}

pub fn decode_to_workspace(
  binary: BitArray,
  workspace: Workspace,
) -> Result(Workspace, String) {
  case binary {
    <<>> -> Ok(workspace)
    _ -> {
      use #(key, binary) <- result.try(decoding.read_key(binary))
      case key.field_number {
        1 -> {
          use #(id, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.int_field_decoder,
          ))
          decode_to_workspace(binary, Workspace(..workspace, id: id))
        }
        2 -> {
          use #(name, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_workspace(binary, Workspace(..workspace, name: name))
        }
        3 -> {
          use #(addit_users, binary) <- result.try(
            decoding.decode_repeated_field(
              binary,
              key.wire_type,
              user_field_decoder(),
            ),
          )
          decode_to_workspace(
            binary,
            Workspace(
              ..workspace,
              users: list.append(workspace.users, addit_users),
            ),
          )
        }
        _ -> Error("Invalid field_number")
      }
    }
  }
}

pub const workspace_field_encoder = FieldEncoder(wire.Len, encode_workspace)

fn workspace_field_decoder() {
  FieldDecoder(wire.Len, decode_to_workspace(_, empty_workspace))
}

pub type User {
  User(id: Int, email: String)
}

pub const empty_user = User(0, "")

pub fn encode_user(user: User) -> BitArray {
  <<>>
  |> bit_array.append(encoding.encode_field(
    1,
    user.id,
    encoding.int_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    2,
    user.email,
    encoding.string_field_encoder,
  ))
}

pub fn decode_to_user(binary: BitArray, user: User) -> Result(User, String) {
  case binary {
    <<>> -> Ok(user)
    _ -> {
      use #(key, binary) <- result.try(decoding.read_key(binary))
      case key.field_number {
        1 -> {
          use #(id, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.int_field_decoder,
          ))
          decode_to_user(binary, User(..user, id: id))
        }
        2 -> {
          use #(email, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_user(binary, User(..user, email: email))
        }
        _ -> Error("Invalid field_number")
      }
    }
  }
}

pub const user_field_encoder = FieldEncoder(wire.Len, encode_user)

fn user_field_decoder() {
  FieldDecoder(wire.Len, decode_to_user(_, empty_user))
}

pub type Message {
  Message(
    id: Int,
    domain: Domain,
    action: Action,
    item: List(Item),
    list: List(ItemList),
    workspace: List(Workspace),
  )
}

pub const empty_message = Message(0, empty_domain, empty_action, [], [], [])

pub fn encode_message(message: Message) -> BitArray {
  <<>>
  |> bit_array.append(encoding.encode_field(
    1,
    message.id,
    encoding.int_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    2,
    message.domain,
    domain_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    3,
    message.action,
    action_field_encoder,
  ))
  |> bit_array.append(encoding.encode_repeated_field(
    4,
    message.item,
    item_field_encoder,
  ))
  |> bit_array.append(encoding.encode_repeated_field(
    5,
    message.list,
    item_list_field_encoder,
  ))
  |> bit_array.append(encoding.encode_repeated_field(
    6,
    message.workspace,
    workspace_field_encoder,
  ))
}

pub fn decode_to_message(
  binary: BitArray,
  message: Message,
) -> Result(Message, String) {
  case binary {
    <<>> -> Ok(message)
    _ -> {
      use #(key, binary) <- result.try(decoding.read_key(binary))
      case key.field_number {
        1 -> {
          use #(id, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.int_field_decoder,
          ))
          decode_to_message(binary, Message(..message, id: id))
        }
        2 -> {
          use #(domain, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            domain_field_decoder(),
          ))
          decode_to_message(binary, Message(..message, domain: domain))
        }
        3 -> {
          use #(action, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            action_field_decoder(),
          ))
          decode_to_message(binary, Message(..message, action: action))
        }
        4 -> {
          use #(addit_item, binary) <- result.try(
            decoding.decode_repeated_field(
              binary,
              key.wire_type,
              item_field_decoder(),
            ),
          )
          decode_to_message(
            binary,
            Message(..message, item: list.append(message.item, addit_item)),
          )
        }
        5 -> {
          use #(addit_list, binary) <- result.try(
            decoding.decode_repeated_field(
              binary,
              key.wire_type,
              item_list_field_decoder(),
            ),
          )
          decode_to_message(
            binary,
            Message(..message, list: list.append(message.list, addit_list)),
          )
        }
        6 -> {
          use #(addit_workspace, binary) <- result.try(
            decoding.decode_repeated_field(
              binary,
              key.wire_type,
              workspace_field_decoder(),
            ),
          )
          decode_to_message(
            binary,
            Message(
              ..message,
              workspace: list.append(message.workspace, addit_workspace),
            ),
          )
        }
        _ -> Error("Invalid field_number")
      }
    }
  }
}

pub const message_field_encoder = FieldEncoder(wire.Len, encode_message)

fn message_field_decoder() {
  FieldDecoder(wire.Len, decode_to_message(_, empty_message))
}
