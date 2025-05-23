import acrostic/decoding.{type FieldDecoder, FieldDecoder}
import acrostic/encoding.{type FieldEncoder, FieldEncoder}
import acrostic/wire
import gleam/bit_array
import gleam/int
import gleam/list
import gleam/result

pub type Errors {
  Unknown
  InvalidCredentials
  TokenExpired
  UserAlreadyExist
  ConstraintFailed
}

pub const empty_errors = Unknown

pub fn encode_errors(errors: Errors) -> BitArray {
  case errors {
    Unknown -> encoding.encode_varint(0)
    InvalidCredentials -> encoding.encode_varint(1)
    TokenExpired -> encoding.encode_varint(2)
    UserAlreadyExist -> encoding.encode_varint(3)
    ConstraintFailed -> encoding.encode_varint(4)
  }
}

fn decode_to_errors(binary: BitArray) -> Result(Errors, String) {
  case decoding.to_varint(binary, 0) {
    0 -> Ok(Unknown)
    1 -> Ok(InvalidCredentials)
    2 -> Ok(TokenExpired)
    3 -> Ok(UserAlreadyExist)
    4 -> Ok(ConstraintFailed)
    _ ->
      Error(
        "Decode to errors failed: " <> bit_array.base64_encode(binary, False),
      )
  }
}

pub const errors_field_encoder = FieldEncoder(wire.VarInt, encode_errors)

fn errors_field_decoder() {
  FieldDecoder(wire.VarInt, decode_to_errors)
}

// struct start -----------------------------------
pub type TokenMessage {
  TokenMessage(access_token: String, refresh_token: String, refresh_after: Int)
}

pub const empty_token_message = TokenMessage("", "", 0)

pub fn encode_token_message(token_message: TokenMessage) -> BitArray {
  <<>>
  |> bit_array.append(encoding.encode_field(
    1,
    token_message.access_token,
    encoding.string_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    2,
    token_message.refresh_token,
    encoding.string_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    3,
    token_message.refresh_after,
    encoding.int_field_encoder,
  ))
}

pub fn decode_to_token_message(
  binary: BitArray,
  token_message: TokenMessage,
) -> Result(TokenMessage, String) {
  case binary {
    <<>> -> Ok(token_message)
    _ -> {
      use #(key, binary) <- result.try(decoding.read_key(binary))
      case key.field_number {
        1 -> {
          use #(access_token, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_token_message(
            binary,
            TokenMessage(..token_message, access_token: access_token),
          )
        }
        2 -> {
          use #(refresh_token, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_token_message(
            binary,
            TokenMessage(..token_message, refresh_token: refresh_token),
          )
        }
        3 -> {
          use #(refresh_after, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.int_field_decoder,
          ))
          decode_to_token_message(
            binary,
            TokenMessage(..token_message, refresh_after: refresh_after),
          )
        }
        _ -> Error("Invalid field_number")
      }
    }
  }
}

pub const token_message_field_encoder = FieldEncoder(
  wire.Len,
  encode_token_message,
)

fn token_message_field_decoder() {
  FieldDecoder(wire.Len, decode_to_token_message(_, empty_token_message))
}

pub type AuthenticateRequest {
  AuthenticateRequest(email: String, password: String)
}

pub const empty_authenticate_request = AuthenticateRequest("", "")

pub fn encode_authenticate_request(
  authenticate_request: AuthenticateRequest,
) -> BitArray {
  <<>>
  |> bit_array.append(encoding.encode_field(
    1,
    authenticate_request.email,
    encoding.string_field_encoder,
  ))
  |> bit_array.append(encoding.encode_field(
    2,
    authenticate_request.password,
    encoding.string_field_encoder,
  ))
}

pub fn decode_to_authenticate_request(
  binary: BitArray,
  authenticate_request: AuthenticateRequest,
) -> Result(AuthenticateRequest, String) {
  case binary {
    <<>> -> Ok(authenticate_request)
    _ -> {
      use #(key, binary) <- result.try(decoding.read_key(binary))
      case key.field_number {
        1 -> {
          use #(email, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_authenticate_request(
            binary,
            AuthenticateRequest(..authenticate_request, email: email),
          )
        }
        2 -> {
          use #(password, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_authenticate_request(
            binary,
            AuthenticateRequest(..authenticate_request, password: password),
          )
        }
        _ -> Error("Invalid field_number")
      }
    }
  }
}

pub const authenticate_request_field_encoder = FieldEncoder(
  wire.Len,
  encode_authenticate_request,
)

fn authenticate_request_field_decoder() {
  FieldDecoder(wire.Len, decode_to_authenticate_request(
    _,
    empty_authenticate_request,
  ))
}

pub type RefreshTokenRequest {
  RefreshTokenRequest(refresh_token: String)
}

pub const empty_refresh_token_request = RefreshTokenRequest("")

pub fn encode_refresh_token_request(
  refresh_token_request: RefreshTokenRequest,
) -> BitArray {
  <<>>
  |> bit_array.append(encoding.encode_field(
    1,
    refresh_token_request.refresh_token,
    encoding.string_field_encoder,
  ))
}

pub fn decode_to_refresh_token_request(
  binary: BitArray,
  refresh_token_request: RefreshTokenRequest,
) -> Result(RefreshTokenRequest, String) {
  case binary {
    <<>> -> Ok(refresh_token_request)
    _ -> {
      use #(key, binary) <- result.try(decoding.read_key(binary))
      case key.field_number {
        1 -> {
          use #(refresh_token, binary) <- result.try(decoding.decode_field(
            binary,
            key.wire_type,
            decoding.string_field_decoder,
          ))
          decode_to_refresh_token_request(
            binary,
            RefreshTokenRequest(
              ..refresh_token_request,
              refresh_token: refresh_token,
            ),
          )
        }
        _ -> Error("Invalid field_number")
      }
    }
  }
}

pub const refresh_token_request_field_encoder = FieldEncoder(
  wire.Len,
  encode_refresh_token_request,
)

fn refresh_token_request_field_decoder() {
  FieldDecoder(wire.Len, decode_to_refresh_token_request(
    _,
    empty_refresh_token_request,
  ))
}
