defmodule Richter.Query do
  alias Richter.Repo
  alias Richter.Schema.{User, Event, UserEvent}
  alias Richter.Transform, as: T

  import Ecto.Query
  import Geo.PostGIS

  @doc """
  Given a normal map representing user data (e.g., from a subscription),
  prepare and validate the data through a changeset. Insert the
  changeset if valid and return the User struct; otherwise, return
  a map of errors in the changeset.
  """
  def insert_user(user) do
    insert_one(User, user)
  end

  @doc """
  Given a list of USGC earthquake events ("features") as normal maps,
  prepare and validate the maps, and then perform a bulk insert.

  Note: `on_conflict: :nothing` is there so that we can attempt to insert
  the same event (same "id") multiple times without raising a constraint
  error. Many contiguous queries of hourly event data will return common
  events.

  TODO
  ----
  * Consolidate changeset processing and insert so that all the insert
    functions can share similar abstractions.
  """
  def insert_events(events) do
    changesets =
      events
      |> T.prepare_event_list()

    Repo.transaction(fn ->
      changesets
      |> Enum.each(&Repo.insert!(&1, on_conflict: :nothing))
    end)
  end

  @doc """
  """
  def insert_user_event(user_event) do
    insert_one(UserEvent, user_event)
  end

  # For the given `schema` insert a single `data` payload.
  defp insert_one(schema, data) do
    changeset = schema.changeset(struct(schema), data)

    if changeset.valid? do
      {:ok, Repo.insert!(changeset)}
    else
      {:error, extract_changeset_errors(changeset)}
    end
  end

  defp extract_changeset_errors(changeset) do
    for {k, v} <-
          changeset.errors,
        do: [{k, elem(v, 0)}] |> Enum.into(%{})
  end
end
