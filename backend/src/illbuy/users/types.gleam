import gleam/dynamic/decode
import gleam/option.{type Option, Some}

pub fn id_password(email: String, password: String) {
  use id <- decode.field(0, decode.int)
  use hashed_password <- decode.field(1, decode.string)
  decode.success(User(
    Some(id),
    Some(email),
    Some(password),
    Some(hashed_password),
  ))
}

pub fn decode_id() {
  use id <- decode.field(0, decode.int)
  decode.success(id)
}

pub type User {
  User(
    id: Option(Int),
    email: Option(String),
    password: Option(String),
    hashed_password: Option(String),
  )
}

pub type TokenAudience {
  Access
  Refresh
}

pub fn token_audience_to_string(audience: TokenAudience) -> String {
  case audience {
    Access -> "a"
    Refresh -> "r"
  }
}

pub fn string_to_token_audience(audience: String) -> Result(TokenAudience, Nil) {
  case audience {
    "r" -> Ok(Refresh)
    "a" -> Ok(Access)
    _ -> Error(Nil)
  }
}

pub type Token {
  Token(subject: Int, audience: TokenAudience, expiration: Int)
}
