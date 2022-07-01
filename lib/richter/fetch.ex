defmodule Richter.Fetch do
  @moduledoc """
  Accessors for fetching hourly and monthly earthquake data from the USGS website.
  """

  @url_1hour "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_hour.geojson"
  @url_30days "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"

  @doc """
  Get earthquakes with magnitude greater than 1 within the last hour.

  The `with` block is included here in case pre-processing of the body is needed
  later.
  """
  def get_last_1hour() do
    with {:ok, body} <- request(@url_1hour) do
      {:ok, body}
    end
  end

  @doc """
  Get earthquakes with magnitude greater than 1 within the last 30 days. The URL
  used to retrieve this data returns earthquakes of _all_ magnitudes. The list of
  quakes under the "features" key of the body is filtered to include quakes with
  magnitude ("mag" key) >= 1.
  """
  def get_last_30days() do
    with {:ok, body} <- request(@url_30days) do
      {:ok, filter_body(body)}
    end
  end

  # Request data from the URL and return the response body.
  #
  # Rather than use `Req.get!`, which raises an exception in case of an error, this
  # function uses the more primitive `Req.request`, which allows explicit handling of
  # error messages. Error handling may not be needed initially, but it'll be easy to
  # add later.
  #
  # This is also where HTTP status codes would be handled, if needed.
  defp request(url) do
    case Req.request(method: :get, url: url) do
      {:ok, %Req.Response{body: body}} -> {:ok, body}
      {:error, _error} -> {:error, "something bad happened"}
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
