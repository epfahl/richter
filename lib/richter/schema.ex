defmodule Richter.Schema.User do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "user" do
    field(:endpoint, :string)
    field(:filters, :map)
    has_many(:user_event, Richter.Schema.UserEvent)
    has_many(:event, through: [:user_event, :event])

    timestamps()
  end
end

defmodule Richter.Schema.Event do
  use Ecto.Schema

  @primary_key {:id, :string, []}

  schema "event" do
    field(:details, :map)

    timestamps()
  end
end

defmodule Richter.Schema.UserEvent do
  use Ecto.Schema

  schema "user_event" do
    belongs_to(:user, Richter.Schema.User)
    belongs_to(:event, Richter.Schema.Event)

    timestamps()
  end
end
