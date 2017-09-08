# ApiAuth

HMAC API authentication.

This is Elixir implementation should be compatible with [https://github.com/mgomes/api_auth](https://github.com/mgomes/api_auth)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `api_auth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:api_auth, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/api_auth](https://hexdocs.pm/api_auth).

## Usage

### HTTPotion

To make a GET request:

```elixir
headers = ApiAuth.headers([], "/path", client_id, secret_key)

"http://example.com/path"
|> HTTPotion.get(headers: headers)
```

Or a POST request:

```elixir
body    = "post body"
headers = ApiAuth.headers([], "/post/path", client_id, secret_key,
                          method: "POST", content: body)

"http://example.com/post/path"
|> HTTPotion.post(body: body, headers: headers)
```

### HTTPoison

To make a GET request:

```elixir
headers = ApiAuth.headers([], "/path", client_id, secret_key)

"http://example.com/path"
|> HTTPoison.get(headers)
```

Or a POST request:

```elixir
body    = "{}"
headers = ApiAuth.headers(["Content-Type": "application/json"], "/post/path",
                           client_id, secret_key, method: "POST", content: body)

"http://example.com/path"
|> HTTPoison.post(body, headers)
```

### Phoenix

To authenticate all requests for a particular pipeline, create a new
plug and configure it to use `ApiAuth`.
Note that you have to add it to `endpoint.ex` and not `router.ex` because it's
[not always possible](https://github.com/phoenixframework/phoenix/issues/459)
to get the body of a request in a regular pipeline:

```elixir
# lib/myapp_web/endpoint.ex

defmodule Myapp.Endpoint do
  use Phoenix.Endpoint, otp_app: :myapp

  ...

  # Add the `Authentication` plug immediately before `Plug.Parsers`.
  # What `mount: "api"` does is limit the routes that are authenticated.
  # In this example, only routes that start with `api/` are authenticated.
  plug Myapp.Plugs.Authentication, mount: "api"

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  ...
end
```

```elixir
# lib/myapp_web/plugs/authentication.ex

defmodule Myapp.Plugs.Authentication do
  import Plug.Conn

  def init(default), do: default

  def call(conn, [mount: mount]) do
    case conn.path_info do
      [^mount | _] -> authorize(conn)
      _            -> conn
    end
  end

  defp authorize(conn) do
    client_id  = "client id"
    secret_key = "secret key"
    body       = get_body(conn)

    %{
      req_headers: req_headers,
      request_path: request_path,
      method: method,
    } = conn

    # you may need to add `content_algorithm: :md5` depending on the code signing the request
    # see the compatibility section of the README
    authentic = ApiAuth.authentic?(req_headers, request_path, client_id,
                                   secret_key, method: method,
                                   content: body)

    if authentic do
      conn
    else
      conn
      |> send_resp(:unauthorized, "")
      |> halt()
    end
  end

  defp get_body(conn) do
    case read_body(conn) do
      {:ok, body, _conn} -> body
      _                  -> ""
    end
  end
end
```

If you have multiple clients, you'll need to look up the secret key by client id.
The plug would look similar to the one above but with a few changes:

```elixir
defmodule Myapp.Plugs.Authentication do
  import Plug.Conn

  def call(conn, _default) do
    client_id = ApiAuth.client_id(conn.req_headers)
    {:ok, secret_key} = Myapp.Client.get_secret_key(client_id)

    ...
  end

  ...
end
```

### Compatibility

Using this library with [https://github.com/mgomes/api_auth](https://github.com/mgomes/api_auth) for Ruby/Rails
requires some configuration.

By default, the Rails library uses `sha1` as the HMAC hash function.
It also uses `md5` as the hash function for hashing content in PUT and POST requests.
This library uses `sha256` by default for both.

To make a request to a server which is using the Rails library with default configuration:

```elixir
headers
|> ApiAuth.headers(path, client_id, secret_key, content_algorithm: :md5,
                   signature_algorithm: :sha)
```

Or with `sha256` as the HMAC hash function:

```elixir
headers
|> ApiAuth.headers(path, client_id, secret_key, content_algorithm: :md5)
```

To tell if a request generated by the Rails library is authentic:

```elixir
headers
|> ApiAuth.authentic?(path, client_id, secret_key, content_algorithm: md5,
                      signature_algorithm: sha)
```

Or with `sha256` as the HMAC function:

```elixir
headers
|> ApiAuth.authentic?(path, client_id, secret_key, content_algorithm: md5)
```

## Running tests

* `mix deps.get`
* `mix test`
