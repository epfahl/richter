defmodule Richter.Transform do
  @moduledoc """
  Useful data transformations.
  """
  alias Richter.Schema.{Event}

  @doc """
  Prepare a list of raw event payloads by 1) restructuring USGS features to have
  the proper event shape, 2) validating and creating a changeset for each event, and
  3) filtering for valid changesets
  """
  def prepare_event_list(features) do
    features
    |> Enum.map(&prepare_event/1)
    |> Enum.map(&Event.changeset(%Event{}, &1))
    |> Enum.filter(fn c -> c.valid? end)
  end

  @doc """
  Prepare a single USGS features by 1) extracting event time and
  transforming it to a DateTime, 2) extracing the long and lat and creating
  a Geo.Point struct, and 3) returning a properly shaped payload.
  """
  def prepare_event(feature) do
    # Feature ID used as event primary key
    id = feature["id"]

    # Quake magnitude
    mag = feature["mag"]

    # Convert from unix millisecond "time" (presumably UTC) to DateTime
    time =
      feature["properties"]["time"]
      |> DateTime.from_unix!(:millisecond)

    # From "geometry", create lnglat as a Geo.Point struct
    lnglat = geometry_to_point(feature)

    %{id: id, time: time, magnitude: mag, lnglat: lnglat, details: feature}
  end

  @doc """
  Given a USGS event ("feature"), extract long and lat and repack as a
  Geo.Point struct.
  """
  def geometry_to_point(%{"geometry" => %{"coordinates" => [long, lat, _]}}) do
    %Geo.Point{coordinates: {long, lat}, srid: 4326}
  end
end
