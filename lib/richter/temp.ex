defmodule Richter.Temp do
  @moduledoc """
  Temporary quake fetcher and processor for testing during development.
  """

  @webhook_url "http://localhost:8765/notify"

  def run() do
    # Store each of the quakes as %{id => feature}
    # Only write to the store if the ID is new.
    # Show a messagre if the ID is new.
    IO.puts("\n\nRequest at time #{DateTime.utc_now()}...")

    with {:ok, body} <- Richter.Fetch.get_last_1hour() do
      body["features"]
      |> Enum.each(fn f ->
        id = f["id"]

        with :error <- Richter.Store.fetch(id) do
          response =
            Req.post!(@webhook_url, json: Map.put(f, "custom_message", "Hi from Richter!"))

          response.body |> Jason.decode!() |> IO.inspect()
          IO.puts("New quake found with ID #{id}")
          Richter.Store.put(id, f)
        end
      end)
    end

    # inspect all keys to see how we're doing
    IO.puts("\nAll the keys so far at #{DateTime.utc_now()}:")
    Richter.Store.get_all() |> Map.keys() |> IO.inspect()
  end
end
