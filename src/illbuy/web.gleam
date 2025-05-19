import argus
import dot_env
import dot_env/env
import gleam/result
import illbuy/types
import pog
import wisp

pub fn create_context() -> types.Context {
  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load
  let connection = case
    result.unwrap(env.get_string("POSTGRESQL_DB"), "") |> pog.url_config()
  {
    Ok(connection) ->
      connection
      |> pog.connection_parameter("application_name", "illbuy")
      |> pog.pool_size(10)
    Error(_) -> panic as "🗃️ Something wrong with $POSTGRESQL_DB variable"
  }
  let db = pog.connect(connection)

  let secret_key = result.unwrap(env.get_string("SECRET_KEY"), "")
  let password_validator =
    result.unwrap(env.get_string("PASSWORD_VALIDATOR"), "")
  let hasher = argus.hasher()

  let env =
    types.Env(secret: secret_key, password_validator: password_validator)
  types.Context(db: db, env: env, hasher: hasher)
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handle_request(req)
}
