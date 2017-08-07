defmodule ApiAuth.UriHeader do
  @moduledoc false

  @keys      [:"X-Original-URI", :"X-ORIGINAL-URI", :"X_ORIGINAL_URI", :"HTTP_X_ORIGINAL_URI"]
  @value_key :uri

  alias ApiAuth.HeaderValues

  def headers(hv, uri) do
    hv
    |> HeaderValues.copy(@keys, @value_key, uri)
    |> HeaderValues.transform(@value_key, "/", &parse_uri/1)
  end

  def parse_uri(uri) do
    %{path: path, query: query} = URI.parse(uri)

    path = if path && path != "", do: path, else: "/"

    if query, do: "#{path}?#{query}", else: path
  end
end
