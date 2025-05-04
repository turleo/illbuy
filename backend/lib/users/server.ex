defmodule Illbuy.Users.Server do
  use Agent

  require Logger
  alias Illbuy.Users.Pb.{TokenResponse, UserRequest, RefreshTokenRequest}
  alias Illbuy.Users.Repo

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def proceed_request(name, params) do
    try do
      case name do
        "Login" ->
          UserRequest.decode(params) |> login |> TokenResponse.encode
        "RefreshToken" ->
          RefreshTokenRequest.decode(params) |> refresh_token |> TokenResponse.encode
        _ ->
          TokenResponse.encode(%TokenResponse{error: :ConstrainFailed})
      end
    rescue
      e ->
        Logger.info("can't parse params, #{inspect e}")
        TokenResponse.encode(%TokenResponse{error: :ConstrainFailed})
    end
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
