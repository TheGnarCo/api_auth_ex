defmodule ApiAuth.ContentHashHeaderTest do
  use ExUnit.Case

  alias ApiAuth.ContentHashHeader
  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare

  describe "headers" do
    test "this is not a PUT or POST and it doesn't compute the hash" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.headers("GET", "", :sha256)
              |> HeaderValues.get(:content_hash)

      assert value == ""
    end

    test "it computes the content hash correctly" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.headers("POST", "foo", :sha256)
              |> HeaderValues.get(:content_hash)

      assert value == "LCa0a2j/xo/5m0U8HTBBNBNCLXBkg7+g+YpeiGJm564="
    end

    test "it computes the md5 hash correctly" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.headers("POST", "foo", :md5)
              |> HeaderValues.get(:content_hash)

      assert value == "rL0Y20zC+Fzt72VPzMSk2A=="
    end

    test "it gets the value from the headers" do
      headers = ["X-APIAuth-Content-Hash": "hash", "Content-MD5": "md5-hash", foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.headers("POST", "foo", :sha256)
              |> HeaderValues.get(:content_hash)

      assert value == "hash"
    end

    test "it gets the md5 from the headers" do
      headers = ["Content-MD5": "md5-hash", foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.headers("POST", "foo", :md5)
              |> HeaderValues.get(:content_hash)

      assert value == "md5-hash"
    end

    test "it adds to the header if there is no key" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.headers("POST", "foo", :sha256)
              |> HeaderValues.unwrap()
              |> Keyword.fetch!(:"X-APIAuth-Content-Hash")

      assert value == "LCa0a2j/xo/5m0U8HTBBNBNCLXBkg7+g+YpeiGJm564="
    end

    test "it adds to the header if there is no md5 key" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.headers("POST", "foo", :md5)
              |> HeaderValues.unwrap()
              |> Keyword.fetch!(:"Content-MD5")

      assert value == "rL0Y20zC+Fzt72VPzMSk2A=="
    end

    test "it does not change an existing header" do
      headers = ["X-APIAuth-Content-Hash": "hash", "Content-MD5": "md5-hash", foo: "bar"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> ContentHashHeader.headers("POST", "foo", :md5)
                    |> HeaderValues.unwrap()

      assert new_headers == headers
    end
  end

  describe "override" do
    test "this is not a PUT or POST and it doesn't compute the hash" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.override("GET", "", :sha256)
              |> HeaderValues.get(:content_hash)

      assert value == ""
    end

    test "it computes the content hash correctly" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.override("POST", "foo", :sha256)
              |> HeaderValues.get(:content_hash)

      assert value == "LCa0a2j/xo/5m0U8HTBBNBNCLXBkg7+g+YpeiGJm564="
    end

    test "it computes the md5 hash correctly" do
      headers = [foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.override("POST", "foo", :md5)
              |> HeaderValues.get(:content_hash)

      assert value == "rL0Y20zC+Fzt72VPzMSk2A=="
    end

    test "it overrides the value from the headers" do
      headers = ["X-APIAuth-Content-Hash": "hash", "Content-MD5": "md5-hash", foo: "bar"]
      value = headers
              |> HeaderValues.wrap()
              |> ContentHashHeader.override("POST", "foo", :sha256)
              |> HeaderValues.get(:content_hash)

      assert value == "LCa0a2j/xo/5m0U8HTBBNBNCLXBkg7+g+YpeiGJm564="
    end

    test "it updates an existing header" do
      headers = ["X-APIAuth-Content-Hash": "hash", "Content-MD5": "md5-hash", foo: "bar"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> ContentHashHeader.override("POST", "foo", :md5)
                    |> HeaderValues.unwrap()

      assert new_headers == ["Content-MD5": "rL0Y20zC+Fzt72VPzMSk2A==", foo: "bar"]
    end
  end

  describe "compare" do
    test "it is true when it is a PUT or POST and the hashes match" do
      valid_headers = ["Content-MD5": "foo"]
      request_headers = ["X-APIAuth-Content-Hash": "foo"]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> ContentHashHeader.compare("POST")
      |> HeaderCompare.to_boolean()
      |> assert()
    end

    test "it is false when it is a PUT or POST request and the hashes don't match" do
      valid_headers = ["Content-MD5": "foo"]
      request_headers = ["X-APIAuth-Content-Hash": "bar"]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> ContentHashHeader.compare("PUT")
      |> HeaderCompare.to_boolean()
      |> refute()
    end

    test "it is false when it is a PUT or POST request and one side is missing" do
      valid_headers = ["Content-MD5": "foo"]
      request_headers = []

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> ContentHashHeader.compare("PUT")
      |> HeaderCompare.to_boolean()
      |> refute()
    end

    test "it is true when it is not a PUT or POST request" do
      valid_headers = ["Content-MD5": "foo"]
      request_headers = ["X-APIAuth-Content-Hash": "bar"]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> ContentHashHeader.compare("GET")
      |> HeaderCompare.to_boolean()
      |> assert()
    end
  end
end
