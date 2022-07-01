defmodule Richter.Schema.User do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "user" do
    field(:endpoint, :string)
    field(:filters, {:array, :map})
    many_to_many(:event, Richter.Schema.Event, join_through: Richter.Schema.UserEvent)

    timestamps()
  end
end
