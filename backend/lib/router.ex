defmodule Illbuy.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  post "/UserService/:name" do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    answer = Illbuy.Users.Server.proceed_request(name, body)
    send_resp(conn, 200, answer)
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
