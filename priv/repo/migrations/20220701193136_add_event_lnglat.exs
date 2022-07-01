defmodule Richter.Repo.Migrations.AddEventLnglat do
  use Ecto.Migration

  def change do
    execute("alter table event add column lnglat geometry(Point, 4326)")
  end
end
