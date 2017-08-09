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

## Running tests

* `mix deps.get`
* `mix test`
