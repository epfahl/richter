defmodule Richter.Router do
  @moduledoc """
  HTTP API to process subscriptions and to test webhook requests from the
  Richter earthquake service.
  """

  use Plug.Router

  alias Richter.Query, as: Q
  alias Richter.Subscription, as: S

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  # POST endpoint for subscriptions.
  #
  # Example JSON subscription payload:
  #
  # {
  #   "endpoint": "https://receiver.mywebservice.com/earthquakes",
  #   "filters": [
  #     {
  #       "type": "magnitude",
  #       "minimum": 1.0
  #     }
  #   ]
  # }
  #
  # Acknoledgements have status codes 200 (success) or 400 (malformed
  # subscription payload), and a body of the form
  #
  # %{
  #   data: nil | echo ofsubscription data,
  #   errors: error message | [error messages]
  # }
  #
  post "/subscribe" do
    with {:ok, updated_body} <- S.update_subscription(conn.body_params),
         {:ok, user} <- Q.insert_user(updated_body) do
      resp =
        %{data: S.create_user_response_data(user), errors: []}
        |> Jason.encode!()

      send_resp(conn, 200, resp)
    else
      {:error, errors} ->
        resp =
          %{data: nil, errors: errors}
          |> Jason.encode!()

        send_resp(conn, 400, resp)
    end
  end

  # POST endpoint for testing the notification webhook
  #
  # The default testing webhook URL is http://localhost:8765/notify
  #
  # The request payload should have the structure of a single USGS earthquake
  # event ("feature"). An example payload:
  #
  # {
  #   "type": "Feature",
  #   "properties": {
  #     "mag": 2.36,
  #     "place": "2km E of Commerce, CA",
  #     "time": 1618944913520,
  #     "updated": 1618945143221,
  #     "url": "https://earthquake.usgs.gov/earthquakes/eventpage/ci39857648",
  #     "detail": "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/ci39857648.geojson",
  #     "tsunami": 0,
  #     "type": "earthquake",
  #     "title": "M 2.4 - 2km E of Commerce, CA"
  #   },
  #   "geometry": {
  #     "type": "Point",
  #     "coordinates": [
  #       -118.1325,
  #       34.0018333,
  #       16.86
  #     ]
  #   },
  #   "id": "ci39857648"
  # }
  #
  # Acknoledgements have a body of the form
  #
  # %{
  #   data: nil | binary | map,
  #   errors: [error messages]
  # }
  #
  post "/notify" do
    resp =
      %{data: conn.body_params, errors: []}
      |> Jason.encode!()

    send_resp(conn, 200, resp)
  end

  match _ do
    send_resp(conn, 404, "Something is very wrong.")
  end
end
