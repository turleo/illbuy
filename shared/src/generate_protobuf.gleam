import acrostic

pub fn main() {
  acrostic.gen(
    ["priv/protobuf/users.proto"],
    to: "src/illbuy_shared/pb/users.gleam",
    flags: acrostic.Flags(False, False),
  )
}
