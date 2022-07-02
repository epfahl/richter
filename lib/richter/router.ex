defmodule Richter.Router do
  @moduledoc """
  HTTP API to process subscriptions and to test webhook requests from the
  Richter earthquake service.
  """

  use Plug.Router
  alias Richter.Query

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  # Post endpoint for subscriptions.
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
  post "/subscribe" do
    case Query.insert_user(conn.body_params) do
      {:ok, user} ->
        resp =
          %{data: create_user_response(user), errors: []}
          |> Jason.encode!()

        send_resp(conn, 200, resp)

      {:error, errors} ->
        resp =
          %{data: nil, errors: errors}
          |> Jason.encode!()

        send_resp(conn, 400, resp)
    end

    # time = DateTime.utc_now() |> DateTime.to_unix()

    # resp =
    #   Map.merge(
    #     %{
    #       "details" => conn.body_params
    #     },
    #     %{id: UUID.uuid4(), start: time}
    #   )

    # send_resp(conn, 200, resp |> Jason.encode!())
  end

  # Post endpoint for testing the notification webhook.
  post "/notify" do
    resp = %{data: conn.body_params, errors: []} |> Jason.encode!()
    send_resp(conn, 200, resp)
  end

  match _ do
    send_resp(conn, 404, "Something is very wrong.")
  end

  defp create_user_response(user) do
    deleted_keys = [:__meta__, :inserted_at, :updated_at, :event]

    start = user.inserted_at

    user
    |> Map.from_struct()
    |> Map.put(:start, start)
    |> delete_keys(deleted_keys)
  end

  defp delete_keys(map, keys) do
    map
    |> Enum.filter(fn {k, _v} -> not Enum.member?(keys, k) end)
    |> Enum.into(%{})
  end
end
