defmodule Richter.Application do
  use Application

  @impl true
  @doc """
  Note that `Richter.Store` needs to be started before `Richter.Scheduler`,
  because the scheduler calls the store on init. This took me too long to
  figure out!
  """
  def start(_type, _args) do
    children = [
      {Richter.Store, []},
      {Richter.Scheduler,
       [
         mfa: [Richter.Test, :test, ["Hi from Richter!"]],
         period: :timer.seconds(3)
       ]}
    ]

    opts = [strategy: :one_for_one, name: Richter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
