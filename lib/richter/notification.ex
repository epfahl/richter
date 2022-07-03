defmodule Richter.Notification do
  @moduledoc """
  Handle transformations, queries, and the webhook for user notification.
  """
  alias Richter.Util, as: U
  alias Richter.Query, as: Q

  @doc """
  Post a single earthquake event to the webhook URL of a given user.
  """
  def send_notification(webhook_url, event, user_id) do
    with {:ok, _response_body} <- U.request(webhook_url, :post, json: event) do
      IO.puts("""
      Notification successfully sent.
        User: #{user_id}
        Event: #{event.id}
        Time: #{DateTime.utc_now()}
      """)

      # Insert join on request acknoledgement
      Q.insert_user_event(%{user_id: user_id, event_id: event.id})
    end
  end
end
