defmodule Illbuy.Workspaces.Pb.FullWorkspaceProps do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field(:id, 1, type: :int64)
  field(:name, 2, type: :string)
  field(:emails, 3, repeated: true, type: :string)
end

defmodule Illbuy.Workspaces.Pb.WorkspaceProps do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field(:id, 1, type: :int64)
  field(:name, 2, type: :string)
end

defmodule Illbuy.Workspaces.Pb.WorkspaceList do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field(:workspaces, 1, repeated: true, type: Illbuy.Workspaces.Pb.WorkspaceProps)
end

defmodule Illbuy.Workspaces.Pb.NewWorkspace do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field(:name, 1, type: :string)
end

defmodule Illbuy.Workspaces.Pb.ChangeWorkspaceUser do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field(:id, 1, type: :int64)
  field(:email, 2, type: :string)
end
