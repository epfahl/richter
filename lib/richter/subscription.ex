defmodule Richter.Subscription do
  @moduledoc """
  Operations related to user subscription.
  """
  alias Richter.Schema.User
  alias Richter.Util, as: U

  @required_filter_types ["magnitude", "event_age_hours"]
  @default_max_event_age_hours 1.0
  @default_min_magnitude 1.0

  @doc """
  Validate and update the subscription body as needed.
  """
  def update_subscription(data) do
    with {:ok, data} <- validate_subscription(data) do
      {:ok, update_subscription_filters(data)}
    end
  end

  @doc """
  Validate the user subscription body.

  ## Notes
  * _This is basically a stub._
  * TODO: Changesets should be used for this.
  """
  def validate_subscription(%{"endpoint" => e, "filters" => f} = data)
      when is_binary(e) and is_list(f),
      do: {:ok, data}

  def validate_subscription(_), do: {:error, "invalid subscription structure"}

  @doc """
  Update subscription body to include requried filters and default values.
  """
  def update_subscription_filters(data) do
    filters = process_filters(data["filters"])
    Map.put(data, "filters", filters)
  end

  @doc """
  Given a User struct, return the response payload for subscription.
  """
  def create_user_response_data(%User{} = user) do
    deleted_keys = [:__meta__, :inserted_at, :updated_at, :event]

    start = user.inserted_at

    user
    |> Map.from_struct()
    |> Map.put(:start, start)
    |> U.delete_keys(deleted_keys)
  end

  @doc """
  Process user notification filters with required values and defaults.

  Notes
  -----
  * This could be expanded and made more robust by extending the declarative
    filter language and performaing more checks on filter values. Ideally,
    this would be done in a user-facing UI.
  """
  def process_filters(filters) do
    filter_types =
      filters
      |> Enum.map(fn f -> f["type"] end)
      |> MapSet.new()

    required_types = MapSet.new(@required_filter_types)

    new_filters =
      MapSet.difference(required_types, filter_types)
      |> Enum.map(&create_filter/1)

    filters ++ new_filters
  end

  defp create_filter("magnitude" = ft) do
    %{"type" => ft, "minimum" => @default_min_magnitude}
  end

  defp create_filter("event_age_hours" = ft) do
    %{"type" => ft, "maximum" => @default_max_event_age_hours}
  end
end
