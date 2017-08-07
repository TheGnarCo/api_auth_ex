defmodule ApiAuth do
  @moduledoc """
  This is the ApiAuth module.

  It provides an HMAC authentication system for APIs.
  """

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

  alias ApiAuth.HeaderValues

  def headers(request_headers, uri, client_id, secret_key, opts \\ []) do
    method              = opts |> Keyword.get(:method, "GET") |> String.upcase()
    content             = opts |> Keyword.get(:content, "")
    content_algorithm   = opts |> Keyword.get(:content_algorithm, :sha256)
    signature_algorithm = opts |> Keyword.get(:signature_algorithm, :sha256)

    HeaderValues.wrap(request_headers)
    |> ApiAuth.ContentTypeHeader.headers()
    |> ApiAuth.DateHeader.headers()
    |> ApiAuth.UriHeader.headers(uri)
    |> ApiAuth.ContentHashHeader.headers(method, content, content_algorithm)
    |> ApiAuth.AuthorizationHeader.headers(method, client_id, secret_key, signature_algorithm)
    |> HeaderValues.unwrap()
  end
end
