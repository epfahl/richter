# Extra types from the `geo_postgis` library (see https://github.com/bryanjos/geo_postgis).
Postgrex.Types.define(
  Richter.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)
