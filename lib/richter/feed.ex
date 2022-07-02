defmodule Richter.Feed do
  alias Richter.Fetch
  alias Richter.Query

  def get_and_insert_hourly_events() do
    with {:ok, %{"features" => events}} <- Fetch.get_last_1hour() do
      Query.insert_events(events)
    end
  end
end
