import argus
import dot_env
import dot_env/env
import gleam/dict
import gleam/otp/actor
import gleam/result
import illbuy/types
import illbuy/websocket/kv_actor
import pog

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

  let assert Ok(user_actor) = actor.start(dict.new(), kv_actor.handle_message)
  let assert Ok(workspace_actor) =
    actor.start(dict.new(), kv_actor.handle_message)
  let assert Ok(list_actor) = actor.start(dict.new(), kv_actor.handle_message)
  let kv_actors =
    types.KvActors(
      users: user_actor,
      workspaces: workspace_actor,
      lists: list_actor,
    )

  let env =
    types.Env(secret: secret_key, password_validator: password_validator)
  types.Context(db: db, env: env, hasher: hasher, kv_actors: kv_actors)
}
