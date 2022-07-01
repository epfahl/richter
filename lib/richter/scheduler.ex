defmodule Richter.Scheduler do
  @moduledoc """
  A simple GenServer-based scheduler that accepts an MFA argument for a function
  to call quasi-periodically. In this implementation, the schduler is blocked
  until the scheduled task completes. This will introduce drift into the
  timing if execution time is significant. It is advisable to wrap execution in
  an async process, perhaps with `Task.start` or `Task.async`.

  A more robust, but still relatively simple, solution would be to use something
  like the `Quantum` library to achieve cron-like functionality.
  """
  use GenServer

  def start_link([mfa: [_module, _function, _args], period: _period] = state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    execute(state)
    {:ok, state}
  end

  @doc """
  Info callback that responds to `Process.send_after`.
  """
  def handle_info(:work, state) do
    execute(state)
    {:noreply, state}
  end

  @doc """
  Execute the MFA and trigger the `handle_info` callback for the running
  scheduler process.
  """
  def execute(mfa: [module, function, args], period: period) do
    apply(module, function, args)
    Process.send_after(self(), :work, period)
  end
end
