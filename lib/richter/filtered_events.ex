defmodule Richter.FilteredEvents do
  @moduledoc """
  Handle queries for events filtered by location, distance, and age.
  """

  alias Richter.Util, as: U
  alias Richter.Query, as: Q

  @doc """
  Given request `data`, return a list of event details that satisfy the request
  filter criteria for location, distance, and age.

  Example request data:
  %{
    "coordinates" => %{"long" => -122.26770501875019, "lat" => 37.80736777456761},
    "distance_km" => 100.0,
    "max_age_hours" => 24.0
  }

  ## Notes
  * The age is determined relative to "now" when the function is called, rather
    than the time of request or some other fixed time.
  * The filtering on time is done here instead of the DB for expedience.
    Filtering in the DB would be preferable when optimizing for performance.
  """
  def get_filtered_event_details(%{
        lat: lat,
        long: long,
        max_distance_km: max_d_km,
        max_age_hours: max_age
      }) do
    Q.get_near_events(lat, long, max_d_km)
    |> Enum.filter(fn e ->
      hours = U.datetime_diff_hours(DateTime.utc_now(), e.time)
      hours <= max_age
    end)
    |> Enum.map(fn e -> e.details end)
  end
end
