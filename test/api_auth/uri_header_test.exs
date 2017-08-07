defmodule ApiAuth.UriHeaderTest do
  use ExUnit.Case

  alias ApiAuth.UriHeader
  alias ApiAuth.HeaderValues

  describe "headers" do
    test "it gets the value from a content type header" do
      headers = [foo: "bar", "X-Original-URI": "/test"]
      value = headers
              |> HeaderValues.wrap()
              |> UriHeader.headers("/other")
              |> HeaderValues.get(:uri)

      assert value == "/test"
    end

    test "it sets a default value of empty string" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> UriHeader.headers("/other")
              |> HeaderValues.get(:uri)

      assert value == "/other"
    end

    test "it does not change the headers" do
      headers = [foo: "bar"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> UriHeader.headers("/other")
                    |> HeaderValues.unwrap()

      assert new_headers == headers
    end

    test "it removes the host part of the uri" do
      headers = [foo: "bar", "X-Original-URI": "https://www.example.com/test?redirect=https://www.google.com"]
      value = headers
              |> HeaderValues.wrap()
              |> UriHeader.headers("/other")
              |> HeaderValues.get(:uri)

      assert value == "/test?redirect=https://www.google.com"
    end

    test "the default uri is /" do
      headers = [foo: "bar", "X-Original-URI": "https://www.example.com"]
      value = headers
              |> HeaderValues.wrap()
              |> UriHeader.headers("/other")
              |> HeaderValues.get(:uri)

      assert value == "/"
    end
  end
end
