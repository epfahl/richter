defmodule Richter.Repo.Migrations.CreatePostgisExtension do
  use Ecto.Migration

  def change do
    execute("create extension if not exists postgis")
  end
end
