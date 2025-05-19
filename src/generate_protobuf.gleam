import acrostic

pub fn main() {
  acrostic.gen(
    ["priv/protobuf/users.proto"],
    to: "src/illbuy/users/pb.gleam",
    flags: acrostic.Flags(False, False),
  )
}
