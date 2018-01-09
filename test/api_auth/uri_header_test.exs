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

    test "it sets puts a header if there isn't one" do
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
      value = []
              |> HeaderValues.wrap()
              |> UriHeader.headers("https://www.example.com/foo")
              |> HeaderValues.get(:uri)

      assert value == "/foo"
    end

    test "it does not remove the get params from the uri" do
      value = []
              |> HeaderValues.wrap()
              |> UriHeader.headers("/foo?a=b")
              |> HeaderValues.get(:uri)

      assert value == "/foo?a=b"
    end

    test "the default uri is /" do
      value = []
              |> HeaderValues.wrap()
              |> UriHeader.headers("https://www.example.com")
              |> HeaderValues.get(:uri)

      assert value == "/"
    end
  end

  describe "override" do
    test "it overrides the value in the header" do
      headers = [foo: "bar", "X-Original-URI": "/test"]
      value = headers
              |> HeaderValues.wrap()
              |> UriHeader.override("/other")
              |> HeaderValues.get(:uri)

      assert value == "/other"
    end

    test "it changse the headers" do
      headers = [foo: "bar"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> UriHeader.override("/other")
                    |> HeaderValues.unwrap()

      assert new_headers == ["X-Original-URI": "/other", foo: "bar"]
    end
  end
end
