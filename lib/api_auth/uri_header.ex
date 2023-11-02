defmodule ApiAuth.UriHeader do
  @moduledoc false

  @keys [:"X-Original-URI", :"X-ORIGINAL-URI", :X_ORIGINAL_URI, :HTTP_X_ORIGINAL_URI]
  @header_key :"X-Original-URI"
  @value_key :uri

  alias ApiAuth.HeaderValues

  def headers(hv, uri) do
    hv
    |> HeaderValues.copy(@keys, @value_key, uri)
    |> HeaderValues.transform(@value_key, "/", &parse_uri/1)
  end

  def override(hv, uri) do
    hv
    |> HeaderValues.put(@keys, @header_key, @value_key, uri)
    |> HeaderValues.transform(@value_key, "/", &parse_uri/1)
  end

  def parse_uri(uri) do
    %{path: path, query: query} = URI.parse(uri)

    case query do
      nil -> value_for(path)
      "" -> value_for(path)
      _ -> "#{path}?#{query}"
    end
  end

  defp value_for(path) do
    if path && path != "", do: path, else: "/"
  end
end
