defmodule Richter.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:event, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:details, :map)

      timestamps()
    end

  end
end
