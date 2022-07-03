defmodule Richter.Application do
  use Application

  @default_scheduler_period :timer.seconds(30)

  @doc """
  Note that `Richter.Store` needs to be started before `Richter.Scheduler`,
  because the scheduler calls the store on init. (This took me too long to
  figure out!)
  """
  def start(_type, _args) do
    port = System.get_env("PORT") || "8765" |> String.to_integer()

    children = [
      {Plug.Cowboy, scheme: :http, plug: Richter.Router, port: port},
      Richter.Repo,
      create_scheduler_child_spec(
        :event_scheduler,
        Richter.EventData,
        :get_and_insert_last_1hour_events,
        @default_scheduler_period
      ),
      create_scheduler_child_spec(
        :notification_scheduler,
        Richter.Notification,
        :notify_all_users,
        @default_scheduler_period
      )
    ]

    opts = [strategy: :one_for_one, name: Richter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Create scheduler child spec maps given unique ID, atom function name in MFA,
  # and scheduler period in ms.
  defp create_scheduler_child_spec(id, mod, fun, period) do
    %{
      id: id,
      start:
        {Richter.Scheduler, :start_link,
         [
           [
             mfa: [mod, fun, []],
             period: period
           ]
         ]}
    }
  end
end
