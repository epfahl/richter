defmodule Richter.Util do
  @moduledoc """
  Obligatory dumping ground for generally useful utilities that lack a specific
  home.
  """

  @doc """
  Submit and HTTP request for the given `url`, method (e.g., `:get` or `:post`), and
  options (e.g., `json: <json payload>`).

  Rather than use `Req.get!` or `Req.post!`, which raise an exception in case of
  an error, this function uses the more primitive `Req.request`, which allows
  explicit handling of error messages. Error handling may not be needed initially,
  but it'll be easy to add and extend later.
  """
  def request(url, method, opts \\ []) do
    args = [method: method, url: url] ++ opts

    case Req.request(args) do
      {:ok, %Req.Response{body: body}} -> {:ok, body}
      {:error, _error} -> {:error, "something bad happened"}
    end
  end

  @doc """
  Compute the difference between two `DateTime` values in hours.

  ## Examples

    iex> dt1 = ~N[2022-07-03 01:00:00] |> DateTime.from_naive!("Etc/UTC")
    iex> dt2 = ~N[2022-07-03 02:00:00] |> DateTime.from_naive!("Etc/UTC")
    iex> Richter.Util.datetime_diff_hours(dt2, dt1)
    1.0
  """
  def datetime_diff_hours(dt1, dt2) do
    DateTime.diff(dt1, dt2) / 3600.0
  end

  @doc """
  Delete `keys` from a `map`.

  ## Examples

    iex> map = %{a: 1, b: 2, c: 3, d: 4}
    iex> keys = [:b, :d]
    iex> Richter.Util.delete_keys(map, keys)
    %{a: 1, c: 3}
  """
  def delete_keys(map, keys) when is_map(map) and is_list(keys) do
    map
    |> Enum.filter(fn {k, _v} -> not Enum.member?(keys, k) end)
    |> Enum.into(%{})
  end
end
