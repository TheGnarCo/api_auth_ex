defmodule ApiAuth.HeaderValues do
  @moduledoc false

  def wrap(headers) do
    { headers, %{} }
  end

  def unwrap({ headers, _assigns }) do
    headers
  end

  def transform({ headers, assigns }, key, default, fun) do
    { headers, Map.update(assigns, key, default, fun) }
  end

  def get({ _headers, assigns }, key, default \\ "") do
    Map.get(assigns, key, default)
  end

  def copy({ headers, assigns }, keys, value_key, default \\ "") do
    header = Enum.find(headers, fn { k, _v } -> Enum.member?(keys, k) end)

    new_assigns = case header do
      { _k, v } -> assigns |> Map.put(value_key, v)
      _         -> assigns |> Map.put(value_key, default)
    end

    { headers, new_assigns }
  end

  def put({ headers, assigns }, keys, header_key, value_key, default) do
    clean_headers = Enum.reject(headers, fn { k, _v } -> Enum.member?(keys, k) end)

    {
      clean_headers  |> Keyword.put(header_key, default),
      assigns        |> Map.put(value_key, default)
    }
  end

  def put_new({ headers, assigns }, keys, header_key, value_key, default) do
    header = Enum.find(headers, fn { k, _v } -> Enum.member?(keys, k) end)

    new_headers = case header do
      { _k, _v } -> headers
      _          -> headers |> Keyword.put(header_key, default)
    end

    new_assigns = case header do
      { _k, v } -> assigns |> Map.put(value_key, v)
      _         -> assigns |> Map.put(value_key, default)
    end

    { new_headers, new_assigns }
  end
end
