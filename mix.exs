defmodule Richter.MixProject do
  use Mix.Project

  def project do
    [
      app: :richter,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Richter.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.3.0"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.3"},
      {:uuid, "~> 1.1"},
      {:ecto_sql, "~> 3.8"},
      {:postgrex, "~> 0.16.3"},
      {:geo_postgis, "~> 3.4"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
