defmodule Richter.Repo.Migrations.UserEvent do
  use Ecto.Migration

  def change do
    create table(:user_event) do
      add(:user_id, references(:user, type: :uuid))
      add(:event_id, references(:event, type: :string))

      timestamps()
    end
  end
end
