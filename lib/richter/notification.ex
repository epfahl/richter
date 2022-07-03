defmodule Richter.Notification do
  @moduledoc """
  Handle transformations, queries, and the webhook for user notification.
  """
  alias Richter.Util, as: U

  @doc """
  Post a single earthquake event to the webhook URL of a given user.
  """
  def send_notification(webhook_url, event, user_id) do
    with {:ok, response_body} <- U.request(webhook_url, :post, json: event) do
      now = DateTime.utc_now()
      "Notification successfully sent to #{user_id} at #{now}"
      IO.inspect(response_body)
      # create join on ack
    end
  end
end
