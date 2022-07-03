defmodule Richter.Fetch do
  @moduledoc """
  Fetch hourly and monthly earthquake data from the USGS website.
  """
  alias Richter.Util, as: U

  @url_1hour "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_hour.geojson"
  @url_30days "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"

  @doc """
  Get earthquakes with magnitude greater than 1 within the last hour.

  The `with` block is included here in case pre-processing of the body or error
  handling is needed later.
  """
  def get_last_1hour() do
    with {:ok, body} <- U.request(@url_1hour, :get) do
      {:ok, body}
    end
  end

  @doc """
  Get earthquakes with magnitude greater than 1 within the last 30 days. The URL
  used to retrieve this data returns earthquakes of _all_ magnitudes. The list of
  quakes under the "features" key of the body is filtered to include quakes with
  magnitude ("mag" key) >= 1 to be consistent with the feed from the endpoint for
  hourly data.
  """
  def get_last_30days() do
    with {:ok, body} <- U.request(@url_30days, :get) do
      {:ok, filter_body(body)}
    end
  end

  # Filter the response body to include only earthquakes with magnitude >= 1.
  defp filter_body(body) do
    body
    |> Map.update!("features", fn fs ->
      Enum.filter(fs, &(&1["mag"] >= 1))
    end)
  end
end
