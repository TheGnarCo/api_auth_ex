defmodule ApiAuth.AuthorizationHeaderTest do
  use ExUnit.Case

  alias ApiAuth.AuthorizationHeader
  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare

  describe "override" do
    test "it calculates the signature" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
      value = headers
              |> HeaderValues.wrap()
              |> ApiAuth.DateHeader.headers()
              |> AuthorizationHeader.override("GET", "1044", "123", :sha)
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
              |> AuthorizationHeader.override("PUT", "1044", "123", :sha256)
              |> HeaderValues.get(:authorization)

      assert value == "APIAuth-HMAC-SHA256 1044:5JhErRhsIbN2+O595t/Rkax2n7w/YZ0f92BYgZFN5ds="
    end

    test "it writes the signature to the headers" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> ApiAuth.DateHeader.headers()
                    |> AuthorizationHeader.override("GET", "1044", "123", :sha)
                    |> HeaderValues.unwrap()

      assert new_headers == [Authorization: "APIAuth 1044:49FglhLqXWuJqBu5SQOH4F8D1Og=",
                             DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
    end

    test "it overwrites the existing header" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT", AUTHORIZATION: "foo"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> ApiAuth.DateHeader.headers()
                    |> AuthorizationHeader.override("GET", "1044", "123", :sha)
                    |> HeaderValues.unwrap()

      assert new_headers == [Authorization: "APIAuth 1044:49FglhLqXWuJqBu5SQOH4F8D1Og=",
                             DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
    end
  end

  describe "compare" do
    test "it is true when the values are the same" do
      valid_headers = [Authorization: "foo"]
      request_headers = [AUTHORIZATION: "foo"]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> AuthorizationHeader.compare()
      |> HeaderCompare.to_boolean()
      |> assert()
    end

    test "it is false when the values are different" do
      valid_headers = [AUTHORIZATION: "foo"]
      request_headers = [Authorization: "bar"]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> AuthorizationHeader.compare()
      |> HeaderCompare.to_boolean()
      |> refute()
    end

    test "it is false when one of the sides is missing" do
      valid_headers = [AUTHORIZATION: "foo"]
      request_headers = []

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> AuthorizationHeader.compare()
      |> HeaderCompare.to_boolean()
      |> refute()
    end
  end

  describe "extract_client_id" do
    test "it extracts the client id" do
      headers = [Authorization: "APIAuth-HMAC-SHA256 test:v5+Ooq88txd0cFyfSXYn03EFK/NQW9Gepk5YIdkZ4qM="]

      client_id = headers
                  |> AuthorizationHeader.extract_client_id()

      assert client_id == {:ok, "test"}
    end

    test "it works with different kinds of authorization headers" do
      headers = [AUTHORIZATION: "APIAuth 1044:49FglhLqXWuJqBu5SQOH4F8D1Og="]

      client_id = headers
                  |> AuthorizationHeader.extract_client_id()

      assert client_id == {:ok, "1044"}
    end

    test "it returns an error when there is no client id" do
      headers = [Authorization: "APIAuth-HMAC-SHA256 :v5+Ooq88txd0cFyfSXYn03EFK/NQW9Gepk5YIdkZ4qM="]

      client_id = headers
                  |> AuthorizationHeader.extract_client_id()

      assert client_id == :error
    end

    test "it returns an error when the authorization header is nonsense" do
      headers = [Authorization: "zoboomafoo"]

      client_id = headers
                  |> AuthorizationHeader.extract_client_id()

      assert client_id == :error
    end

    test "it returns an error when there is no authorization header" do
      headers = []

      client_id = headers
                  |> AuthorizationHeader.extract_client_id()

      assert client_id == :error
    end
  end
end
