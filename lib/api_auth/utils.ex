defmodule ApiAuth.Utils do
  @moduledoc false

  def find(headers, keys) do
    pair = Enum.find(headers, member_fun(keys))

    case pair do
      {_k, v} -> {:ok, v}
      _ -> :error
    end
  end

  def reject(headers, keys) do
    Enum.reject(headers, member_fun(keys))
  end

  def convert(headers) do
    Enum.map(headers, &convert_key/1)
  end

  defp member_fun(keys) do
    fn {k, _v} -> Enum.member?(keys, k) end
  end

  defp convert_key({key, value}) when is_bitstring(key) do
    new_key =
      key
      |> String.upcase()
      |> String.to_atom()

    {new_key, value}
  end

  defp convert_key(tuple) do
    tuple
  end
end
