defmodule ApiAuth.ContentTypeHeaderTest do
  use ExUnit.Case

  alias ApiAuth.ContentTypeHeader
  alias ApiAuth.HeaderValues

  describe "headers" do
    test "it gets the value from a content type header" do
      headers = [foo: "bar", "Content-Type": "application/json"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentTypeHeader.headers()
              |> HeaderValues.get(:content_type)

      assert value == "application/json"
    end

    test "it sets a default value of empty string" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentTypeHeader.headers()
              |> HeaderValues.get(:content_type)

      assert value == ""
    end

    test "it does not change the headers" do
      headers = [foo: "bar"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> ContentTypeHeader.headers()
                    |> HeaderValues.unwrap()

      assert new_headers == headers
    end
  end
end
