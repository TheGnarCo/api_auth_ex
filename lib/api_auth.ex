defmodule ApiAuth do
  @moduledoc """
  This is the ApiAuth module.

  It provides an HMAC authentication system for APIs.
  """

  alias Calendar.DateTime, as: DateTime

  @doc """
  Generates an Authorization header

  Returns the string "ApiAuth client_id:<signature>"

  ## Examples

      iex> ApiAuth.authorization("/foo", "id", "secret", method: "GET",
      ...>                       time: "Sat, 01 Jan 2000 00:00:00 GMT" |> Calendar.DateTime.Parse.httpdate!)
      "APIAuth id:Uv9YsGct6RFBFDxn5NhUPGqe+EVRQXrE5QLjVWXkga8="

  """
  def authorization(uri, client_id, secret_key, opts \\ []) do
    method         = opts |> Keyword.get(:method, "GET")
    content_type   = opts |> Keyword.get(:content_type, "")
    content        = opts |> Keyword.get(:content, "")
    content_hash   = opts |> Keyword.get(:content_hash, :sha256)
    hashed_content = opts |> Keyword.get(:hashed_content, hashed(content, content_hash))
    time           = opts |> Keyword.get(:time, DateTime.now_utc)
    separator      = opts |> Keyword.get(:separator, ",")
    signature_hash = opts |> Keyword.get(:signature_hash, :sha256)

    string = canonical_string(
      String.upcase(method),
      content_type,
      hashed_content,
      uri,
      timestamp(time),
      separator
    )

    string
    |> signature(secret_key, signature_hash)
    |> header(client_id)
  end

  defp header(signature, client_id) do
    "APIAuth #{client_id}:#{signature}"
  end

  defp timestamp(time) do
    time
    |> DateTime.Format.httpdate
  end

  defp hashed(content, hash) do
    :crypto.hash(hash, content)
    |> Base.encode64()
  end

  defp canonical_string(method, content_type, hashed_content, request_uri, timestamp, separator) do
    [method, content_type, hashed_content, request_uri, timestamp]
    |> Enum.join(separator)
  end

  defp signature(canonical_string, secret_key, hash) do
    :crypto.hmac(hash, secret_key, canonical_string)
    |> Base.encode64()
  end
end
