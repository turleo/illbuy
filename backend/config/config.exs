import Config

config :illbuy, :database,
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "illbuy"

config :joken,
  default_signer: [
    signer_alg: "HS256",
    key_octet: "secret"
  ]
