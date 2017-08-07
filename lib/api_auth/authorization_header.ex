defmodule ApiAuth.AuthorizationHeader do
  @moduledoc false

  @keys       [:Authorization, :AUTHORIZATION]
  @header_key :Authorization
  @value_key  :authorization

  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare

  def override(hv, method, client_id, secret_key, algorithm) do
    canonical = canonical_string(
      method,
      hv |> HeaderValues.get(:content_type),
      hv |> HeaderValues.get(:content_hash),
      hv |> HeaderValues.get(:uri, "/"),
      hv |> HeaderValues.get(:timestamp)
    )

    authorization = canonical
                    |> signature(secret_key, algorithm)
                    |> header_string(client_id, algorithm)

    hv |> HeaderValues.put(@keys, @header_key, @value_key, authorization)
  end

  defp canonical_string(method, content_type, content_hash, uri, timestamp) do
    [method, content_type, content_hash, uri, timestamp]
    |> Enum.join(",")
  end

  defp signature(canonical_string, secret_key, algorithm) do
    algorithm
    |> :crypto.hmac(secret_key, canonical_string)
    |> Base.encode64()
  end

  def compare(hc) do
    hc |> HeaderCompare.compare(@keys)
  end

  defp header_string(signature, client_id, :sha256) do
    "APIAuth-HMAC-SHA256 #{client_id}:#{signature}"
  end

  defp header_string(signature, client_id, _algorithm) do
    "APIAuth #{client_id}:#{signature}"
  end
end
