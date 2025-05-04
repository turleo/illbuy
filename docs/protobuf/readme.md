## Command for regenerating protobufs
```bash
protoc  --elixir_out=backend/lib/ -I docs/protobuf users/user.proto
bun x pbjs --ts frontend/src/api/pb/user.ts docs/protobuf/users/user.proto
```
Relies on https://github.com/stepancheg/rust-protobuf/tree/master/protobuf-codegen and https://github.com/elixir-protobuf/protobuf