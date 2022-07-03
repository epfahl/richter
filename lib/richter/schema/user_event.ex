defmodule Richter.Schema.UserEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_event" do
    belongs_to(:user, Richter.Schema.User, type: Ecto.UUID)
    belongs_to(:event, Richter.Schema.Event, type: :string)

    timestamps()
  end

  def changeset(user_event, params \\ %{}) do
    user_event
    |> cast(params, [:user_id, :event_id])
    |> validate_required([:user_id, :event_id])
  end
end
