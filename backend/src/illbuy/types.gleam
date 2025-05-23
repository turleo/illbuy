import argus
import gleam/erlang/process
import illbuy/websocket/kv_actor
import pog

pub type Env {
  Env(secret: String, password_validator: String)
}

pub type KvActors {
  KvActors(
    users: process.Subject(kv_actor.Message),
    workspaces: process.Subject(kv_actor.Message),
    lists: process.Subject(kv_actor.Message),
  )
}

pub type Context {
  Context(
    db: pog.Connection,
    hasher: argus.Hasher,
    env: Env,
    kv_actors: KvActors,
  )
}
