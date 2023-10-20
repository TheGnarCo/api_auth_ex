defmodule ApiAuth do
  @moduledoc """
  This is the ApiAuth module.

  It provides an HMAC authentication system for APIs.
  """

  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare
  alias ApiAuth.Utils

  alias ApiAuth.ContentTypeHeader
  alias ApiAuth.DateHeader
  alias ApiAuth.UriHeader
  alias ApiAuth.ContentHashHeader
  alias ApiAuth.ContentHashHeader
  alias ApiAuth.AuthorizationHeader

  @doc """
  Takes a keyword list of headers and arguments necessary for generating the
  Authorization header and returns an updated keyword list of headers.

  ## Examples

      iex> [DATE: "Sat, 01 Jan 2000 00:00:00 GMT", "Content-Type": "application/json"]
      ...> |> ApiAuth.headers("/path", "client_id", "secret_key",
      ...>                    method: "PUT", content: "{\\"foo\\": \\"bar\\"}")
      [Authorization: "APIAuth-HMAC-SHA256 client_id:v5+Ooq88txd0cFyfSXYn03EFK/NQW9Gepk5YIdkZ4qM=",
       "X-APIAuth-Content-Hash": "Qm/ATwS/j9tYMdw3u7bc9w9jo34FpoxupfY+ha5Xk3Y=",
       DATE: "Sat, 01 Jan 2000 00:00:00 GMT",
       "Content-Type": "application/json"]

  """
  def headers(request_headers, uri, client_id, secret_key, opts \\ []) do
    parsed = parse(opts)

    request_headers
    |> Utils.convert()
    |> HeaderValues.wrap()
    |> ContentTypeHeader.headers()
    |> DateHeader.headers()
    |> UriHeader.headers(uri)
    |> ContentHashHeader.headers(parsed.method, parsed.content, parsed.content_algorithm)
    |> AuthorizationHeader.override(
      parsed.method,
      client_id,
      secret_key,
      parsed.signature_algorithm
    )
    |> HeaderValues.unwrap()
  end

  @doc """
  Takes a request header and arguments necessary for validating the Authorization header
  and returns true if the request is authentic and false otherwise

  ## Examples

      iex> headers = ApiAuth.headers([], "/path", "client_id", "secret_key")
      ...> ApiAuth.authentic?(headers, "/path", "client_id", "secret_key")
      true

      iex> headers = ApiAuth.headers([], "/path", "client_id", "secret_key")
      ...> ApiAuth.authentic?(headers, "/path", "client_id", "hacker")
      false

  """
  def authentic?(request_headers, uri, client_id, secret_key, opts \\ []) do
    parsed = parse(opts)

    converted_headers = Utils.convert(request_headers)

    valid = valid_headers(converted_headers, uri, client_id, secret_key, opts)

    valid
    |> HeaderCompare.wrap(converted_headers)
    |> ContentHashHeader.compare(parsed.method)
    |> AuthorizationHeader.compare()
    |> DateHeader.compare()
    |> HeaderCompare.to_boolean()
  end

  @doc """
  Takes a keyword list of headers and pulls the client id from the Authorization header
  returns the {:ok, client_id} or {:error}

  ## Examples

      iex> headers = [Authorization: "APIAuth-HMAC-SHA256 client_id:v5+Ooq88txd0cFyfSXYn03EFK/NQW9Gepk5YIdkZ4qM="]
      ...> ApiAuth.client_id(headers)
      {:ok, "client_id"}

      iex> headers = []
      ...> ApiAuth.client_id(headers)
      :error

  """
  def client_id(headers) do
    headers
    |> Utils.convert()
    |> AuthorizationHeader.extract_client_id()
  end

  defp valid_headers(request_headers, uri, client_id, secret_key, opts) do
    parsed = parse(opts)

    request_headers
    |> HeaderValues.wrap()
    |> ContentTypeHeader.headers()
    |> DateHeader.headers()
    |> UriHeader.override(uri)
    |> ContentHashHeader.override(parsed.method, parsed.content, parsed.content_algorithm)
    |> AuthorizationHeader.override(
      parsed.method,
      client_id,
      secret_key,
      parsed.signature_algorithm
    )
    |> HeaderValues.unwrap()
  end

  defp parse(opts) do
    %{
      method: opts |> Keyword.get(:method, "GET") |> String.upcase(),
      content: opts |> Keyword.get(:content, ""),
      content_algorithm: opts |> Keyword.get(:content_algorithm, :sha256),
      signature_algorithm: opts |> Keyword.get(:signature_algorithm, :sha256)
    }
  end
end
