defmodule ApiAuth do
  @moduledoc """
  This is the ApiAuth module.

  It provides an HMAC authentication system for APIs.
  """

  @doc """
  Generates a map of headers which are used to authenticate the request

  Returns a map with the following key value pairs:
  %{
    "X-APIAuth-Content-HASH" | "Content-MDS" => hash of content (if POST or PUT),
    "DATE" => timestamp formatted as HTTP Date,
    "Authorization" => "APIAuth user_id:signature"
  }

  ## Examples

      iex> ApiAuth.headers("/foo", "id", "secret", method: "GET",
      ...>                       time: "Sat, 01 Jan 2000 00:00:00 GMT" |> Calendar.DateTime.Parse.httpdate!)
      %{"Authorization" => "APIAuth-HMAC-SHA256 id:U/HCVd3+aZpbmRwPgTufT24+Sz0F/cjRSyckW9ZdMSY=",
        "DATE" => "Sat, 01 Jan 2000 00:00:00 GMT"}

      iex> ApiAuth.headers("/bar?search=1", "id", "secret", method: "POST", content: "{\\"id\\": 1}",
      ...>                       time: "Sat, 01 Jan 2000 00:00:00 GMT" |> Calendar.DateTime.Parse.httpdate!)
      %{"Authorization" => "APIAuth-HMAC-SHA256 id:5dcvZxiR9GetYPjdlP6CBFh4MDAMt5e795+gnnMjbqw=",
        "DATE" => "Sat, 01 Jan 2000 00:00:00 GMT",
        "X-APIAuth-Content-Hash" => "NUqu96X27LsvruSfvkeiTgJMtisxg7hToezAHgGSDkk="}

  """
  def headers(uri, client_id, secret_key, opts \\ []) do
    options = parse(opts)

    signature = canonical_string(
      options.method,
      options.content_type,
      options.content_hash,
      uri,
      options.timestamp,
      options.separator
    ) |> signature(secret_key, options.signature_algorithm)

    [
      date_header(options.timestamp),
      content_hash_header(options.method, options.content_algorithm, options.content_hash),
      authorization_header(options.signature_algorithm, client_id, signature),
    ] |> merge_maps()
  end

  defp parse(opts) do
    method              = opts |> Keyword.get(:method, "GET") |> String.upcase()
    content             = opts |> Keyword.get(:content, "")
    content_algorithm   = opts |> Keyword.get(:content_algorithm, :sha256)
    content_type        = opts |> Keyword.get(:content_type, "")
    content_hash        = opts |> Keyword.get(:content_hash, content_hash(method, content, content_algorithm))
    timestamp           = opts |> Keyword.get(:time, Calendar.DateTime.now_utc) |> timestamp()
    separator           = opts |> Keyword.get(:separator, ",")
    signature_algorithm = opts |> Keyword.get(:signature_algorithm, :sha256)

    %{
      method: method,
      content: content,
      content_algorithm: content_algorithm,
      content_type: content_type,
      content_hash: content_hash,
      timestamp: timestamp,
      separator: separator,
      signature_algorithm: signature_algorithm,
    }
  end

  defp date_header(time) do
    %{ "DATE" => time }
  end

  defp content_hash_header(method, hash, content_hash) when method in ["PUT", "POST"] do
    content_hash_header(hash, content_hash)
  end

  defp content_hash_header(_method, _hash, _content_hash) do
    %{}
  end

  defp content_hash_header(:md5, content_hash) do
    %{ "Content-MD5" => content_hash }
  end

  defp content_hash_header(_hash, content_hash) do
    %{ "X-APIAuth-Content-Hash" => content_hash }
  end

  defp authorization_header(:sha256, client_id, signature) do
    %{ "Authorization" => "APIAuth-HMAC-SHA256 #{client_id}:#{signature}" }
  end

  defp authorization_header(_hash, client_id, signature) do
    %{ "Authorization" => "APIAuth #{client_id}:#{signature}" }
  end

  defp timestamp(time) do
    time
    |> Calendar.DateTime.Format.httpdate
  end

  defp content_hash(method, content, hash) when method in ["PUT", "POST"] do
    :crypto.hash(hash, content)
    |> Base.encode64()
  end

  defp content_hash(_method, _content, _hash) do
    ""
  end

  defp canonical_string(method, content_type, content_hash, request_uri, timestamp, separator) do
    [method, content_type, content_hash, request_uri, timestamp]
    |> Enum.join(separator)
  end

  defp signature(canonical_string, secret_key, hash) do
    :crypto.hmac(hash, secret_key, canonical_string)
    |> Base.encode64()
  end

  defp merge_maps(maps) do
    maps
    |> Enum.reduce(&Map.merge/2)
  end
end
