defmodule Richter.Schema.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}

  schema "event" do
    field(:details, :map)
    field(:lnglat, Geo.PostGIS.Geometry)
    field(:time, :utc_datetime)
    field(:magnitude, :float)
    many_to_many(:user, Richter.Schema.User, join_through: Richter.Schema.UserEvent)

    timestamps()
  end

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, [:id, :details, :lnglat, :magnitude, :time])
    |> validate_required([:id, :details, :lnglat, :magnitude, :time])
  end
end
