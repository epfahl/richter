defmodule Richter.EventData do
  @moduledoc """
  Public functions for fetching earthquake event data and inserting into the
  database.
  """

  alias Richter.Fetch
  alias Richter.Query

  @doc """
  Get events from the last hour and insert new events into the database.
  """
  def get_and_insert_last_1hour_events(), do: get_and_insert_events(:hour)

  @doc """
  Get events from the last 30 days and insert new events into the database.
  """
  def get_and_insert_last_30days_events(), do: get_and_insert_events(:month)

  defp get_and_insert_events(interval) do
    with {:ok, %{"features" => events}} <- fetch_fun(interval).() do
      Query.insert_events(events)
    end
  end

  defp fetch_fun(:hour), do: &Fetch.get_last_1hour/0
  defp fetch_fun(:month), do: &Fetch.get_last_30days/0
end
