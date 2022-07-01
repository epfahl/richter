defmodule Richter.Schema.UserEvent do
  use Ecto.Schema

  schema "user_event" do
    belongs_to(:user, Richter.Schema.User)
    belongs_to(:event, Richter.Schema.Event)

    timestamps()
  end
end
