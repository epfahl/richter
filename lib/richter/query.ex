defmodule Richter.Query do
  alias Richter.Repo
  alias Richter.Schema.{User, Event}
  alias Richter.Transforms, as: T

  import Ecto.Query
  import Geo.PostGIS

  @doc """
  Given a normal map representing user data (e.g., from a subscription),
  prepare and validate the data through a changeset. Insert the
  changeset if valid and return the User struct; otherwise, return
  a map of errors in the changeset.
  """
  def insert_user(user) do
    changeset = User.changeset(%User{}, user)

    if changeset.valid? do
      {:ok, Repo.insert!(changeset)}
    else
      {:error, extract_changeset_errors(changeset)}
    end
  end

  @doc """
  Given a list of USGC earthquake events ("features") as normal maps,
  prepare and validate the maps, and then perform a bulk insert.

  Note: `on_conflict: :nothing` is there so that we can attempt to insert
  the same event (same "id") multiple times without raising a constraint
  error. Many contiguous queries of hourly event data will return common
  events.
  """
  def insert_events(events) do
    changesets =
      events
      |> T.prepare_event_list()
      |> IO.inspect()

    Repo.transaction(fn ->
      changesets
      |> Enum.each(&Repo.insert!(&1, on_conflict: :nothing))
    end)
  end

  defp extract_changeset_errors(changeset) do
    for {k, v} <-
          changeset.errors,
        do: [{k, elem(v, 0)}] |> Enum.into(%{})
  end
end
