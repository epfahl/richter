defmodule Richter.Repo.Migrations.AddEventTime do
  use Ecto.Migration

  def change do
    alter table :event do
      add :time, :utc_datetime
    end
  end
end
