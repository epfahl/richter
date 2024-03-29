defmodule Richter.EventData do
  @moduledoc """
  Public functions for fetching earthquake event data and inserting into the
  database.
  """

  alias Richter.Fetch
  alias Richter.Query

  @doc """
  Get events from the last hour and insert new events into the database.

  Notes
  -----
  * This does not check for new events relative to what's already stored. It
    just inserts with impunity, counting on conflict handling to prevent dupes.
    It might make sense to check for new events (ID set difference) before
    insertion, but it's not clear if this would improve performance.
  * TODO: Alternatively, it might make sense to cache (in memory) recently
    inserted event IDs and use this for comparison. This avoids hitting the DB
    and is the best option performance-wise.
  """
  def get_and_insert_last_1hour_events(), do: get_and_insert_events(:hour)

  @doc """
  Get events from the last 30 days and insert new events into the database.

  Notes
  -----
  * See note for `get_and_insert_last_1hour_events`.
  """
  def get_and_insert_last_30days_events(), do: get_and_insert_events(:month)

  # Abstraction to handle event inserts.
  defp get_and_insert_events(interval) do
    with {:ok, %{"features" => features}} <- fetch_fun(interval).() do
      Query.insert_events(features)
    end
  end

  defp fetch_fun(:hour), do: &Fetch.get_last_1hour/0
  defp fetch_fun(:month), do: &Fetch.get_last_30days/0
end
