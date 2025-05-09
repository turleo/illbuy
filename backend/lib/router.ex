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
  use Plug.Router

  plug(:match)
  plug(Illbuy.Users.AuthPlug)
  plug(Illbuy.Router.BodyPlug)
  plug(:dispatch)

  post "/UserService/:name" do
    answer = Illbuy.Users.Server.proceed_request(name, conn)
    send_resp(conn, 200, answer)
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
