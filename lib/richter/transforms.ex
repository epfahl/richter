defmodule Richter.Transforms do
  @moduledoc """
  Useful data transformations.
  """
  alias Richter.Schema.{Event}

  @doc """
  Prepare a list of raw event payloads by 1) restructuring each event to have
  the proper shape, 2) validating and creating a changeset for each event, and
  3) filtering for valid changesets
  """
  def prepare_event_list(events) do
    # changesets =
    events
    |> Enum.map(&prepare_event/1)
    |> Enum.map(&Event.changeset(%Event{}, &1))
    |> Enum.filter(fn c -> c.valid? end)
  end

  @doc """
  Prepare a single USGS event (a "feature") by 1) extracting event time and
  transforming it to a DateTime, 2) extracing the long and lat and creating
  a Geo.Point struct, and 3) returning a properly shaped payload.
  """
  def prepare_event(event) do
    # Feature ID used as event primary key
    id = event["id"]

    # Convert from unix millisecond "time" (presumably UTC) to DateTime
    time =
      event["properties"]["time"]
      |> DateTime.from_unix!(:millisecond)

    # From "geometry", create lnglat as a Geo.Point struct
    lnglat = geometry_to_point(event)

    %{id: id, time: time, lnglat: lnglat, details: event}
  end

  @doc """
  Given a USGS event ("feature"), extract long and lat and repack as a
  Geo.Point struct.
  """
  def geometry_to_point(%{"geometry" => %{"coordinates" => [long, lat, _]}}) do
    %Geo.Point{coordinates: {long, lat}, srid: 4326}
  end
end
