# ApiAuth

HMAC API authentication.

This is Elixir implementation should be compatible with [https://github.com/mgomes/api_auth](https://github.com/mgomes/api_auth)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `api_auth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:api_auth, "~> 0.2.0"}
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

Note that `Plug.Conn.read_body/2` can only be called once. This means that
if you need the body for something else, you have to make sure to save it.
There are also particular issues with JSON APIs due to the way `Plug.Parsers.JSON`
works.

[This issue](https://github.com/phoenixframework/phoenix/issues/459)
has some discussion about these problems and different workarounds.
The sample code below assumes that the raw body has been saved in `conn.assigns.raw_body`.

```elixir
# lib/myapp_web/router.ex

defmodule MyappWeb.Router do
  use MyappWeb, :router

  pipeline :api do
    plug(Myapp.AuthenticationPlug)
  end
end
```

```elixir
# lib/myapp_web/plugs/authentication_plug.ex

defmodule MyappWeb.AuthenticationPlug do
  @moduledoc """
  Authentication plug
  Using the `api_auth` package (https://github.com/TheGnarCo/api_auth_ex#phoenix)
  this plug allows requests to continue through the pipeline only if they
  have a valid HMAC signature.
  """

  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    conn
    |> authorize()
  end

  defp authorize(conn) do
    client_id  = "client id"
    secret_key = "secret key"
    body       = get_body(conn)

    %{
      query_string: query_string,
      req_headers: req_headers,
      request_path: request_path,
      method: method,
    } = conn

    full_path = request_path
    |> URI.parse()
    |> Map.put(:query, query_string)
    |> URI.to_string()

    # you may need to add `content_algorithm: :md5` depending on the code signing the request
    # see the compatibility section of the README
    authentic = ApiAuth.authentic?(req_headers, full_path, client_id,
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

  # in order for this code to work, `read_body/2` must be called somewhere earlier
  # in the pipeline and the result must be stored in `conn.assigns.raw_body`
  # (see https://github.com/phoenixframework/phoenix/issues/459)
  defp get_body(%{assigns: assigns}) do
    case assigns do
      %{raw_body: body} -> body
      _ -> ""
    end
  end
end
```

If you have multiple clients, you'll need to look up the secret key by client id.
The plug would look similar to the one above but with a few changes:

```elixir
defmodule MyappWeb.AuthenticationPlug do
  import Plug.Conn

  defp authorize(conn) do
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

#### Using api_auth_ex as a client
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

#### Using api_auth_ex as a server
To tell if a request generated by the Rails library is authentic:

```elixir
headers
|> ApiAuth.authentic?(path, client_id, secret_key, content_algorithm: :md5,
                      signature_algorithm: :sha)
```

Or with `sha256` as the HMAC function:

```elixir
headers
|> ApiAuth.authentic?(path, client_id, secret_key, content_algorithm: :md5)
```

## Running tests

* `mix deps.get`
* `mix test`

## About The Gnar Company

![The Gnar Company](https://avatars0.githubusercontent.com/u/17011419?s=100&v=4)

If you’re ready to dream it, we’re ready to build it. The Gnar is a custom software company ready to tackle your biggest challenges. Visit [The Gnar Company website](https://www.thegnar.com/) to learn more about us or [contact us](https://www.thegnar.com/contact) to see how we can help design and develop your product.

