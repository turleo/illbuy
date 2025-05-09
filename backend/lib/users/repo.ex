defmodule Illbuy.Users.Repo do
  require Logger
  @hour 60 * 60
  @month @hour * 24 * 30
  @tokenConfig Joken.Signer.parse_config(:default_signer)

  def get_user(email, password) do
    {:ok, response} =
      Postgrex.query(:db, "SELECT id, email, password FROM users.users WHERE email = $1;", [email])

    process_user(email, password, response)
  end

  def verify_access_token(access_token) do
    Joken.verify(access_token, @tokenConfig) |> proceed_verifying
  end

  defp proceed_verifying({:ok, claims}) do
    current_time = DateTime.now!("Etc/UTC") |> DateTime.to_unix()

    if claims["aud"] == "access" and claims["exp"] > current_time do
      {:ok, claims["sub"]}
    else
      {:error, :WrongToken}
    end
  end

  defp proceed_verifying({:error, _}) do
    {:error, :WrongToken}
  end

  def refresh_token(refresh_token) do
    Joken.verify(refresh_token, @tokenConfig) |> proceed_refreshing
  end

  defp proceed_refreshing({:ok, claims}) do
    current_time = DateTime.now!("Etc/UTC") |> DateTime.to_unix()

    if claims["aud"] == "refresh" and claims["exp"] > current_time do
      generate_access_token(claims["sub"])
    else
      {:error, :WrongToken}
    end
  end

  defp proceed_refreshing({:error, _}) do
    {:error, :WrongToken}
  end

  defp process_user(email, password, response) when response.num_rows == 0 do
    Logger.debug("new user")
    hashed_password = Bcrypt.hash_pwd_salt(password)

    proceed_registration(
      Postgrex.query(
        :db,
        "INSERT INTO users.users (email, password) VALUES ($1, $2) RETURNING id;",
        [email, hashed_password]
      )
    )
  end

  defp process_user(_email, password, response) when response.num_rows == 1 do
    Logger.debug("existing user")
    stored_password = response.rows |> Enum.at(0) |> Enum.at(2)

    if Bcrypt.verify_pass(password, stored_password) do
      response.rows |> Enum.at(0) |> Enum.at(0) |> generate_access_token
    else
      {:error, :WrongPassword}
    end
  end

  defp proceed_registration({:ok, response}) do
    response.rows |> Enum.at(0) |> Enum.at(0) |> generate_access_token
  end

  defp proceed_registration({:error, response}) do
    Logger.info("Constrain failed: #{response}")
    {:error, :ConstrainFailed}
  end

  defp generate_access_token(id) do
    current_time = DateTime.now!("Etc/UTC") |> DateTime.to_unix()

    {:ok, access_token, _claims} =
      Joken.encode_and_sign(
        %{"sub" => id, "iat" => current_time, "exp" => current_time + @hour, "aud" => "access"},
        @tokenConfig
      )

    {:ok, refresh_token, _claims} =
      Joken.encode_and_sign(
        %{"sub" => id, "iat" => current_time, "exp" => current_time + @month, "aud" => "refresh"},
        @tokenConfig
      )

    {:ok, access_token, refresh_token}
  end
end
