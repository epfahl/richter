defmodule Richter.Store do
  @moduledoc """
  An in-memory data store.
  """

  use Agent

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def fetch(key) do
    Agent.get(__MODULE__, &Map.fetch(&1, key))
  end

  def get_all() do
    Agent.get(__MODULE__, & &1)
  end

  def put(key, value) do
    Agent.update(__MODULE__, fn state -> Map.put(state, key, value) end)
  end
end
