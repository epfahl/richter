import Config

config :richter, Richter.Repo,
  database: "richter",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  types: Richter.PostgresTypes

# types: Richter.PostgresTypes

config :richter,
  ecto_repos: [Richter.Repo]
