import argus
import pog

pub type Env {
  Env(secret: String, password_validator: String)
}

pub type Context {
  Context(db: pog.Connection, hasher: argus.Hasher, env: Env)
}
