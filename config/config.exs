import Config

config :richter, Richter.Repo,
  database: "quakes",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432

config :richter,
  ecto_repos: [Richter.Repo]
