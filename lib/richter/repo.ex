defmodule Richter.Repo do
  use Ecto.Repo,
    otp_app: :richter,
    adapter: Ecto.Adapters.Postgres
end
