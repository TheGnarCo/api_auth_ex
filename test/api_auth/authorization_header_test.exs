defmodule ApiAuth.AuthorizationHeaderTest do
  use ExUnit.Case

  alias ApiAuth.AuthorizationHeader
  alias ApiAuth.HeaderValues

  describe "headers" do
    test "it calculates the signature" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
      value = headers
              |> HeaderValues.wrap()
              |> ApiAuth.DateHeader.headers()
              |> AuthorizationHeader.headers("GET", "1044", "123", :sha)
              |> HeaderValues.get(:authorization)

      assert value == "APIAuth 1044:49FglhLqXWuJqBu5SQOH4F8D1Og="
    end

    test "it calcualtes the signature with a body" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT", "Content-Type": "text/plain"]
      value = headers
              |> HeaderValues.wrap()
              |> ApiAuth.DateHeader.headers()
              |> ApiAuth.ContentTypeHeader.headers()
              |> ApiAuth.ContentHashHeader.headers("PUT", "", :md5)
              |> ApiAuth.UriHeader.headers("/resource.xml?foo=bar&bar=foo")
              |> AuthorizationHeader.headers("PUT", "1044", "123", :sha256)
              |> HeaderValues.get(:authorization)

      assert value == "APIAuth-HMAC-SHA256 1044:5JhErRhsIbN2+O595t/Rkax2n7w/YZ0f92BYgZFN5ds="
    end

    test "it writes the signature to the headers" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> ApiAuth.DateHeader.headers()
                    |> AuthorizationHeader.headers("GET", "1044", "123", :sha)
                    |> HeaderValues.unwrap()

      assert new_headers == [Authorization: "APIAuth 1044:49FglhLqXWuJqBu5SQOH4F8D1Og=",
                             DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
    end

    test "it overwrites the existing header" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT", AUTHORIZATION: "foo"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> ApiAuth.DateHeader.headers()
                    |> AuthorizationHeader.headers("GET", "1044", "123", :sha)
                    |> HeaderValues.unwrap()

      assert new_headers == [Authorization: "APIAuth 1044:49FglhLqXWuJqBu5SQOH4F8D1Og=",
                             DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
    end
  end
end
