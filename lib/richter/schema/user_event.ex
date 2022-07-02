defmodule Richter.Schema.UserEvent do
  use Ecto.Schema

  schema "user_event" do
    belongs_to(:user, Richter.Schema.User, type: Ecto.UUID)
    belongs_to(:event, Richter.Schema.Event, type: :string)

    timestamps()
  end
end
