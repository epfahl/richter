defmodule Richter.Schema.Event do
  use Ecto.Schema

  @primary_key {:id, :string, []}

  schema "event" do
    field(:details, :map)
    many_to_many(:user, Richter.Schema.User, join_through: Richter.Schema.UserEvent)

    timestamps()
  end
end