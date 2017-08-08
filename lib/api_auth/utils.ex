defmodule ApiAuth.Utils do
  @moduledoc false

  def find(headers, keys) do
    pair = Enum.find(headers, member_fun(keys))

    case pair do
      {_k, v} -> {:ok, v}
      _       -> :error
    end
  end

  def reject(headers, keys) do
    Enum.reject(headers, member_fun(keys))
  end

  defp member_fun(keys) do
    fn {k, _v} -> Enum.member?(keys, k) end
  end
end
