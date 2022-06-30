defmodule Richter.Router do
  @moduledoc """
  HTTP API to process subscriptions and to test webhook requests from the
  Richter earthquake service.
  """

  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  # Post endpoint for subscriptions.
  #
  # Validation should probably be done with Ecto changesets...?
  post "/subscribe" do
    time = DateTime.utc_now() |> DateTime.to_unix()

    resp =
      Map.merge(
        %{
          "details" => conn.body_params
        },
        %{id: UUID.uuid4(), start: time}
      )

    send_resp(conn, 200, resp |> Jason.encode!())
  end

  # Post endpoint for testing the alert webhook.
  post "/alert" do
    send_resp(conn, 200, conn.body_params |> Jason.encode!())
  end

  match _ do
    send_resp(conn, 404, "Something is very wrong.")
  end
end
