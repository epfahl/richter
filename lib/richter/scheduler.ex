defmodule Richter.Scheduler do
  @moduledoc """
  A simple GenServer-based scheduler that accepts an MFA argument for a function
  to call quasi-periodically. In this implementation, the schduler is blocked
  until the function execution completes. This will introduced drift into the
  timing. If strict periodicity is required, the function could be called
  asynchronously, perhaps with `Task.async`.

  A more robust, but still relatively simple, solution would use something like
  the `Quantum` library to achieve cron-like functionality.
  """
  use GenServer

  def start_link([mfa: [_module, _function, _args], period: _period] = state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    execute(state)
    {:ok, state}
  end

  def handle_info(:work, state) do
    execute(state)
    {:noreply, state}
  end

  def execute(mfa: [module, function, args], period: period) do
    apply(module, function, args)
    Process.send_after(self(), :work, period)
  end
end

defmodule Richter.Test do
  def test(message), do: "Message: #{message}" |> IO.inspect()
end
