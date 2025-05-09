defmodule Illbuy.Users.Server do
  require Logger
  alias Illbuy.Users.Pb.{TokenResponse, UserRequest, RefreshTokenRequest}
  alias Illbuy.Users.Repo

  def proceed_request("Login", conn) do
    try do
      UserRequest.decode(conn.private.body) |> login |> TokenResponse.encode()
    rescue
      e ->
        Logger.info("can't parse params, #{inspect(e)}")
        TokenResponse.encode(%TokenResponse{error: :ConstrainFailed})
    end
  end

  def proceed_request("RefreshToken", conn) do
    try do
      RefreshTokenRequest.decode(conn.private.body) |> refresh_token |> TokenResponse.encode()
    rescue
      e ->
        Logger.info("can't parse params, #{inspect(e)}")
        TokenResponse.encode(%TokenResponse{error: :ConstrainFailed})
    end
  end

  def proceed_request(route, _) do
    Logger.debug("Unknown route #{route}")
    TokenResponse.encode(%TokenResponse{error: :ConstrainFailed})
  end

  @spec login(UserRequest.t()) :: TokenResponse.t()
  def login(request) do
    Repo.get_user(request.email, request.password) |> response
  end

  @spec refresh_token(RefreshTokenRequest.t()) :: TokenResponse.t()
  def refresh_token(request) do
    Repo.refresh_token(request.refreshToken) |> response
  end

  defp response({:ok, access_token, refresh_token}) do
    %TokenResponse{accessToken: access_token, refreshToken: refresh_token}
  end

  defp response({:error, error}) do
    %TokenResponse{error: error}
  end
end
