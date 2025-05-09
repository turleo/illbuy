defmodule Illbuy.Users.AuthPlug do
  import Plug.Conn
  import Illbuy.Users.Repo

  def init(options), do: options

  @spec call(Plug.Conn.t(), []) :: Plug.Conn.t()
  def call(conn, _) do
    get_req_header(conn, "authorization") |> check_auth(conn)
  end

  defp check_auth([token], conn) do
    verify_access_token(token) |> set_authorization(conn)
  end

  defp check_auth(_, conn) do
    set_authorization({:error, nil}, conn)
  end

  defp set_authorization({:ok, user_id}, conn) do
    Plug.Conn.put_private(conn, :user_id, user_id)
  end

  defp set_authorization(_, conn) do
    Plug.Conn.put_private(conn, :user_id, nil)
  end
end
