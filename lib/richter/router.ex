defmodule Richter.Router do
  @moduledoc """
  HTTP API to process subscriptions and to test webhook requests from the
  Richter earthquake service.
  """

  use Plug.Router

  alias Richter.Query, as: Q
  alias Richter.Subscription, as: S
  alias Richter.FilteredEvents, as: F
  alias Richter.Admin, as: A

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

  # POST endpoint for getting events filtered by location, distance, and age.
  # If the
  #
  # Example request payload:
  #
  # %{
  #   "user_id" => "f3a76777-65db-4df2-b65b-70737515a1c8",
  #   "coordinates" => %{"long" => -122.26770501875019, "lat" => 37.80736777456761},
  #   "distance_km" => 100.0,
  #   "max_age_hours" => 24.0
  # }
  #
  post "/filtered_events" do
    %{
      "user_id" => user_id,
      "coordinates" => %{"long" => long, "lat" => lat},
      "max_distance_km" => max_d_km,
      "max_age_hours" => max_age
    } = conn.body_params

    if Q.users_exists?(user_id) do
      filtered_details =
        F.get_filtered_event_details(%{
          lat: lat,
          long: long,
          max_distance_km: max_d_km,
          max_age_hours: max_age
        })

      resp =
        %{data: filtered_details, errors: []}
        |> Jason.encode!()

      send_resp(conn, 200, resp)
    else
      send_resp(conn, 401, "unauthorized user")
    end
  end

  # POST endpoint for admin actions.
  #
  # WARNING: This endpoint is purely for testing; it does not have any auth.
  #
  post "/admin" do
    {status, resp} =
      case A.handle_actions(conn.body_params) do
        :ok -> {200, "successful request"}
        {:error, error} -> {400, error}
      end

    send_resp(conn, status, resp)
  end

  # POST endpoint for testing the notification webhook
  #
  # The default testing webhook URL is http://localhost:8765/notify
  #
  # The payload should have the structure of a single USGS earthquake
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
