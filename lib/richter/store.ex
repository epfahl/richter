defmodule Richter.Store do
  @moduledoc """
  An in-memory data store.
  """

  use Agent

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def get_all() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def put(value) do
    Agent.update(__MODULE__, fn state -> [value | state] end)
  end
end
