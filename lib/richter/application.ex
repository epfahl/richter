defmodule Richter.Application do
  use Application

  @scheduler_period :timer.seconds(30)

  @doc """
  Note that `Richter.Store` needs to be started before `Richter.Scheduler`,
  because the scheduler calls the store on init. (This took me too long to
  figure out!)
  """
  def start(_type, _args) do
    port = System.get_env("PORT") || "8765" |> String.to_integer()

    children = [
      {Plug.Cowboy, scheme: :http, plug: Richter.Webhook, port: port},
      {Richter.Store, %{}},
      {Richter.Scheduler,
       [
         mfa: [Richter.Temp, :run, []],
         period: @scheduler_period
       ]}
    ]

    opts = [strategy: :one_for_one, name: Richter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
