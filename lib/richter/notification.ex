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

    Q.get_all_users()
    |> Enum.each(fn u ->
      user_events =
        Q.get_new_user_events(u.id)
        |> apply_user_filters(u.filters)

      if user_events != [] do
        # FIXME: This concurrently sends a batch of user notifications, but
        # this approach (no linking, no supervision) assumes we don't care about
        # the result or the failure of the operation. It's also not sensitive to
        # network resources or timeouts.
        Task.start(fn ->
          sent_all_user_notifications(u.id, u.endpoint, user_events)
        end)
      end
    end)
  end

  @doc """
  For a given `user_id` and `webhook_url` and list of `events`, send a
  separate notification for each event. These notifications are sent
  sequentially to avoid overwhelming the receiver. A sleep could be added as
  simple (but hacky) rate limiter.
  """
  def sent_all_user_notifications(user_id, webhook_url, events) do
    events
    |> Enum.each(&send_user_notification(user_id, webhook_url, &1))
  end

  @doc """
  Post a single earthquake event to the webhook URL of a given user. On acknowledgement
  of the request, an entry is addeed to the `UserEvent` join table.
  """
  def send_user_notification(user_id, webhook_url, %{id: event_id, details: details}) do
    with {:ok, _response_body} <- U.request(webhook_url, :post, json: details) do
      IO.puts("""
      Notification successfully sent.
        User: #{user_id}
        Event: #{event_id}
        Time: #{DateTime.utc_now()}
      """)

      # Insert user-event join on notification request acknoledgement
      Q.insert_user_event(%{user_id: user_id, event_id: event_id})
    end
  end

  # Apply filters to the list of events. Each filter is a map, and each
  # corresponds to a separate predicate expression.
  #
  # Notes
  # -----
  # * There is an opportunity to generalize the declarative filter language (eg.,
  #   via {key, operation, value} structure) and the actual filtering mechanics.
  defp apply_user_filters(events, filters) do
    events
    |> Enum.filter(fn e ->
      filters
      |> Enum.map(fn f -> filter_predicate(e, f) end)
      |> Enum.all?()
    end)
  end

  # Return a boolean that indicates if the magnitude is at least the minimum
  # given in the user filter.
  defp filter_predicate(e, %{"type" => "magnitude", "minimum" => m}) do
    e.magnitude >= m
  end

  # Return a boolean that indicates if (now - event time) is less than the
  # maximum given in the user filter.
  defp filter_predicate(e, %{"type" => "event_age_hours", "maximum" => m}) do
    hours = U.datetime_diff_hours(DateTime.utc_now(), e.time)
    hours <= m
  end

  # Unhandled filters do have no effect.
  defp filter_predicate(_e, _filter), do: true
end
