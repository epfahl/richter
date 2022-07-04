defmodule Richter.Admin do
  @moduledoc """
  Handle admin action requests.
  """

  alias Richter.EventData, as: E

  @doc """
  Handle admin actions.

  Example payload:
  %{
    "action" => "backfill"
  }

  ## Notes
  * Only "backfill" is handled at this time.
  * This is another place where changesets should be used validation.
  """
  def handle_actions(%{"action" => "backfill"}) do
    # Put this in a Task so that the function promptly returns while the
    # backfill is running. Otherwise, there will likely be a socket timeout
    # for the upstream HTTP request.
    Task.start(fn -> E.get_and_insert_last_30days_events() end)
    :ok
  end

  def handle_actions(%{"action" => _action}) do
    {:error, "unrecognized action name"}
  end

  def handle_actions(_) do
    {:error, "invalid request body"}
  end
end
