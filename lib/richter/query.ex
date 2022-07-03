defmodule Richter.Query do
  alias Richter.Repo
  alias Richter.Schema.{User, Event, UserEvent}
  alias Richter.Transform, as: T

  import Ecto.Query
  import Geo.PostGIS

  @doc """
  Given a normal map representing a user subscription payload,
  prepare and validate the data through a changeset. Insert the
  changeset if valid and return the User struct; otherwise, return
  a map of errors in the changeset.

  Example `user` map:
  %{
    endpoint: "http://myurl.me",
    filters: [
      %{type: "magnitude", minimum: 1.0}
    ]
  }
  """
  def insert_user(user_sub) do
    insert_one(User, user_sub)
  end

  @doc """
  Given a list of USGC earthquake features (earthquake events) as normal maps,
  prepare and validate the maps, and then perform a bulk insert. These features
  are first transformed into proper `Event` payloads before insertion.

  Note: `on_conflict: :nothing` is there so that we can attempt to insert
  the same event (same "id") multiple times without raising a constraint
  error. Many contiguous queries of hourly event data will return common
  events.

  Example feature map:
  %{
    "geometry" => %{
      "coordinates" => [-66.9626666666667, 17.9648333333333, 8.36],
      "type" => "Point"
    },
    "id" => "pr71357203",
    "properties" => %{
      "alert" => nil,
      "cdi" => nil,
      "code" => "71357203",
      "detail" => "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/pr71357203.geojson",
      "dmin" => nil,
      "felt" => nil,
      "gap" => 192,
      "ids" => ",pr71357203,",
      "mag" => 2.01,
      "magType" => "md",
      "mmi" => nil,
      "net" => "pr",
      "nst" => 5,
      "place" => "5 km WSW of Fuig, Puerto Rico",
      "rms" => 0.08,
      "sig" => 62,
      "sources" => ",pr,",
      "status" => "reviewed",
      "time" => 1656793067010,
      "title" => "M 2.0 - 5 km WSW of Fuig, Puerto Rico",
      "tsunami" => 0,
      "type" => "earthquake",
      "types" => ",origin,phase-data,",
      "tz" => nil,
      "updated" => 1656794149300,
      "url" => "https://earthquake.usgs.gov/earthquakes/eventpage/pr71357203"
    },
    "type" => "Feature"
  }

  TODO
  ----
  * Consolidate changeset processing and insert logic so that all the insert
    functions can share similar abstractions.
  """
  def insert_events(features) do
    changesets =
      features
      |> T.prepare_event_list()

    # `Repo.transaction` was needed here because `Repo.insert_all` (bulk
    # insert) doesn't play nice with DB-autogenertated timestamps.
    Repo.transaction(fn ->
      changesets
      |> Enum.each(&Repo.insert!(&1, on_conflict: :nothing))
    end)
  end

  @doc """
  Insert a user-event join entry representing a sent notification.

  Example user-event payload:
  %{
    user_id: "d069ac4c-839f-4cb9-8f66-a58bd80a8350",
    event_id: "pr71357203"
  }
  """
  def insert_user_event(user_event) do
    insert_one(UserEvent, user_event)
  end

  @doc """
  Get events for which the user has not yet been notified and that meet the user's
  filter criteria.
  """
  def get_new_user_events(user_id, _filters) do
    query_new_events(user_id)
    |> Repo.all()
    |> Enum.filter(fn _e -> true end)
  end

  # Query events for which the user has not been notified.
  #
  # Note (TODO?): This does not apply user filters. It might be nice to handle
  # this filtering in the DB, which would entail transformaing declarative
  # filter experssions into query fragments.
  defp query_new_events(user_id) do
    que =
      from(u in Richter.Schema.UserEvent,
        where: u.user_id == ^user_id,
        select: u.event_id
      )

    qeue =
      from(e in Event,
        except: ^que,
        select: e.id
      )

    from(e in Event,
      join: eq in ^qeue,
      on: eq.id == e.id,
      select: e
    )
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

  # Extract changeset errors into a list of maps of the form:
  # [%{key: reason}, ...]
  defp extract_changeset_errors(changeset) do
    for {k, v} <-
          changeset.errors,
        do: [{k, elem(v, 0)}] |> Enum.into(%{})
  end
end
