import Config

# Extra types from the `geo_postgis` library (see https://github.com/bryanjos/geo_postgis).
Postgrex.Types.define(
  Richter.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)

config :richter, Richter.Repo,
  database: "richter",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432
  types: Richter.PostgresTypes

config :richter,
  ecto_repos: [Richter.Repo]
