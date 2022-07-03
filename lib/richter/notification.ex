defmodule Richter.Notification do
  @moduledoc """
  Handle transformations, queries, and the webhook for user notification.
  """
  alias Richter.Util, as: U
  alias Richter.Query, as: Q

  @doc """
  For all users in the database, check for new events that meet user filter
  criteria, and sent event notifications.
  """
  def notify_all_users() do
    IO.puts("""
    Checking for notifications at #{DateTime.utc_now()}.
    """)

    users_with_events =
      Q.get_all_users()
      |> Enum.reduce([], fn u, acc ->
        new_events = Q.get_new_user_events_details(u.id, u.filters)

        if new_events != [] do
          user_events = %{
            user_id: u.id,
            endpoint: u.endpoint,
            events: new_events
          }

          [user_events | acc]
        else
          acc
        end
      end)

    users_with_events |> IO.inspect(label: "users with events")

    # users = Q.get_all_users()
    # # per user, check for new events
    # # if list non-empty, queue notifications
    # # put this on a separate schedule (same period)
  end

  @doc """
  Post a single earthquake event to the webhook URL of a given user.
  """
  def send_notification(user_id, webhook_url, event) do
    with {:ok, _response_body} <- U.request(webhook_url, :post, json: event) do
      IO.puts("""
      Notification successfully sent.
        User: #{user_id}
        Event: #{event.id}
        Time: #{DateTime.utc_now()}
      """)

      # Insert user-event join on notification request acknoledgement
      Q.insert_user_event(%{user_id: user_id, event_id: event.id})
    end
  end
end
