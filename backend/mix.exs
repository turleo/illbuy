defmodule Illbuy.MixProject do
  use Mix.Project

  def project do
    [
      app: :illbuy,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Illbuy, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:protobuf, "~> 0.14.1"},
      {:postgrex, "~> 0.20.0"},
      {:joken, "~> 2.6.2"},
      {:jason, "~> 1.4"},
      {:bcrypt_elixir, "~> 3.3.1"}
    ]
  end
end
