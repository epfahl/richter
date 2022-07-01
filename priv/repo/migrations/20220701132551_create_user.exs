defmodule Richter.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:endpoint, :string)
      add(:filters, :map, default: %{})

      timestamps()
    end

  end
end
