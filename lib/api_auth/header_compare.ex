defmodule ApiAuth.HeaderCompare do
  @moduledoc false

  alias ApiAuth.Utils
  alias Plug.Crypto

  def wrap(valid, request) do
    {:ok, valid, request}
  end

  def compare(hc, keys) do
    compare(hc, keys, &Crypto.secure_compare/2)
  end

  def compare({:ok, valid, request} = hc, keys, fun) do
    with {:ok, valid_value} <- Utils.find(valid, keys),
         {:ok, request_value} <- Utils.find(request, keys),
         true <- fun.(valid_value, request_value) do
      hc
    else
      _ -> :error
    end
  end

  def compare(_hc, _keys, _fun) do
    :error
  end

  def to_boolean({:ok, _valid, _request}) do
    true
  end

  def to_boolean(_hc) do
    false
  end
end
