defmodule ApiAuthTest do
  use ExUnit.Case
  doctest ApiAuth

  describe "headers" do
    test "adds missing headers and signs request" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
                |> ApiAuth.headers("/", "1044", "123", method: "POST")

      expected_headers = [
        Authorization: "APIAuth-HMAC-SHA256 1044:0GZ7kEF4vXa5wjyLYsddgW66Vp1i1i8jA+CO9+9umSI=",
        "X-APIAuth-Content-Hash": "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=",
        DATE: "Sat, 01 Jan 2000 00:00:00 GMT",
      ]

      assert headers == expected_headers
    end
  end

  describe "authentic?" do
    test "it is true when the request is authentic" do
      headers = ApiAuth.headers([], "/", "1044", "123")

      headers
      |> ApiAuth.authentic?("/", "1044", "123")
      |> assert()
    end

    test "it is true when headers are lowercase and strings (like in Phoenix)" do
      headers = ApiAuth.headers([], "/", "1044", "123")
      fun = fn {k, v} -> {String.downcase(Atom.to_string(k)), v} end
      phoenix_headers = Enum.map(headers, fun)

      phoenix_headers
      |> ApiAuth.authentic?("/", "1044", "123")
      |> assert()
    end

    test "it is false when the secret key is different" do
      headers = ApiAuth.headers([], "/", "1044", "123")

      headers
      |> ApiAuth.authentic?("/", "1044", "other")
      |> refute()
    end

    test "it is false when the client id is different" do
      headers = ApiAuth.headers([], "/", "1054", "123")

      headers
      |> ApiAuth.authentic?("/", "1044", "123")
      |> refute()
    end

    test "it verifies the content hash when POST or PUT" do
      headers = ApiAuth.headers([], "/resource", "1044", "123", method: "POST", content: "foo")

      headers
      |> ApiAuth.authentic?("/resource", "1044", "123", method: "POST", content: "foo")
      |> assert()
    end

    test "it is false when the content differs when POST or PUT" do
      headers = ApiAuth.headers([], "/resource", "1044", "123", method: "POST", content: "foo")

      headers
      |> ApiAuth.authentic?("/resource", "1044", "123", method: "POST", content: "bar")
      |> refute()
    end

    test "it is false when the uri in the headers doesn't match the signed uri" do
      headers = ApiAuth.headers([], "/resource", "1044", "123")
      modified_headers = headers |> Keyword.put(:"X-Original-URI", "/other")

      modified_headers
      |> ApiAuth.authentic?("/other", "1044", "123")
      |> refute()
    end

    test "it is false when the hash in the headers doesn't match the signed uri" do
      headers = ApiAuth.headers([], "/resource", "1044", "123", method: "PUT", content: "foo")
      modified_headers = headers |> Keyword.put(:"X-APIAuth-Content-Hash",
                                                "/N4rLtula/QIYB+3If6bXDONEO5CnqBPrlURto+/j7k=")
      modified_headers
      |> ApiAuth.authentic?("/resource", "1044", "123", method: "PUT", content: "bar")
      |> refute()
    end

    test "it is false when more than 15 minutes has passed" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
                |> ApiAuth.headers("/", "1044", "123", method: "POST")

      headers
      |> ApiAuth.authentic?("/", "1044", "123", method: "POST")
      |> refute()
    end
  end
end
