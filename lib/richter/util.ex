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
end
