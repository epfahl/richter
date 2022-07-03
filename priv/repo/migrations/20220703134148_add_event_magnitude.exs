defmodule Richter.Repo.Migrations.AddEventMagnitude do
  use Ecto.Migration

  def change do
    alter table :event do
      add :magnitude, :float
    end
  end
end
