defmodule Illbuy do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Illbuy.Router, options: [port: 8079]}
    ]

    {:ok, database_connection} = Application.fetch_env(:illbuy, :database)
    Postgrex.start_link([pool_size: 5, name: :db] ++ database_connection)

    opts = [strategy: :one_for_one, name: Illbuy]
    Supervisor.start_link(children, opts)
  end
end
