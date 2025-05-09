defmodule Illbuy.Router.BodyPlug do
  import Plug.Conn

  def init(options), do: options

  @spec call(Plug.Conn.t(), []) :: Plug.Conn.t()
  def call(conn, _) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    Plug.Conn.put_private(conn, :body, body)
  end
end

defmodule Illbuy.Router do
  require Logger
  use Plug.Router

  plug(Illbuy.Users.AuthPlug)
  plug(Illbuy.Router.BodyPlug)
  plug(:match)
  plug(:dispatch)

  post "/UserService/:name" do
    answer = Illbuy.Users.Server.proceed_request(name, conn)
    send_resp(conn, 200, answer)
  end

  post "/WorkspaceService/:name" do
    answer = Illbuy.Workspaces.Server.proceed_request(name, conn)
    send_resp(conn, 200, answer)
  end

  options _ do
    send_resp(conn, 204, <<>>)
  end

  match _ do
    Logger.debug("Unknown route #{inspect(conn)}")
    send_resp(conn, 200, <<4, 0, 4>>)
  end
end
