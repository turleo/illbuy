## Command for regenerating protobufs
```bash
# protoc --rs_out frontend/src/protobuf --elixir_out=backend/lib/ -I docs/protobuf user.proto
protoc  --rs_out frontend/src/pb --elixir_out=backend/lib/ -I docs/protobuf users/user.proto
```
Relies on https://github.com/stepancheg/rust-protobuf/tree/master/protobuf-codegen and https://github.com/elixir-protobuf/protobuf