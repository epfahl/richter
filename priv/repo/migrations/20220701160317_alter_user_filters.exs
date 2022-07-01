defmodule Richter.Repo.Migrations.AlterUserFilters do
  use Ecto.Migration

  def change do
      alter table :user do
        remove :filters
        add :filters, {:array, :map}, default: []
      end
  end
end
