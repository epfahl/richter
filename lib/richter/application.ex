defmodule Richter.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Richter.Scheduler,
       [mfa: [Richter.Test, :test, ["Hi from scheduler!"]], period: :timer.seconds(3)]}
    ]

    opts = [strategy: :one_for_one, name: Richter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
