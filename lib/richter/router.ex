defmodule Richter.Router do
  @moduledoc """
  HTTP API to process subscriptions and to test webhook requests from the
  Richter earthquake service.
  """

  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  post "/quake_alert" do
    send_resp(conn, 200, conn.body_params |> Jason.encode!())
  end

  match _ do
    send_resp(conn, 404, "Something is very wrong.")
  end
end
