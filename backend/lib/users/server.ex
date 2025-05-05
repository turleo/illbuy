defmodule Illbuy.Users.Server do
  require Logger
  alias Illbuy.Users.Pb.{TokenResponse, UserRequest, RefreshTokenRequest}
  alias Illbuy.Users.Repo

  def proceed_request("Login", params) do
    try do
      UserRequest.decode(params) |> login |> TokenResponse.encode
    rescue
      e ->
        Logger.info("can't parse params, #{inspect e}")
        TokenResponse.encode(%TokenResponse{error: :ConstrainFailed})
    end
  end

  def proceed_request("RefreshToken", params) do
    try do
      RefreshTokenRequest.decode(params) |> refresh_token |> TokenResponse.encode
    rescue
      e ->
        Logger.info("can't parse params, #{inspect e}")
        TokenResponse.encode(%TokenResponse{error: :ConstrainFailed})
    end
  end

  def proceed_request(_, _) do
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
