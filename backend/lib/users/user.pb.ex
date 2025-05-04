defmodule Illbuy.Users.Pb.Errors do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :WrongPassword, 0
  field :WrongToken, 1
  field :ConstrainFailed, 2
end

defmodule Illbuy.Users.Pb.UserRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :email, 1, type: :string
  field :password, 2, type: :string
end

defmodule Illbuy.Users.Pb.RefreshTokenRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :refreshToken, 1, type: :string
end

defmodule Illbuy.Users.Pb.TokenResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :accessToken, 1, proto3_optional: true, type: :string
  field :refreshToken, 2, proto3_optional: true, type: :string
  field :error, 3, proto3_optional: true, type: Illbuy.Users.Pb.Errors, enum: true
end
