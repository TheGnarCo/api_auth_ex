defmodule ApiAuth.HeaderCompareTest do
  use ExUnit.Case

  alias ApiAuth.HeaderCompare

  describe "wrap" do
    test "it wraps two headers in a header compare structure" do
      valid_headers = [foo: "bar"]
      request_headers = [baz: "bat"]

      hc = HeaderCompare.wrap(valid_headers, request_headers)

      assert hc == {:ok, [foo: "bar"], [baz: "bat"]}
    end
  end

  describe "compare" do
    test "it returns the same tuple when the values are the same" do
      valid_headers = [foo: "bar", baz: "bat"]
      request_headers = [foo: "bar", baz: "cat"]

      hc = HeaderCompare.wrap(valid_headers, request_headers)
      new_hc = hc |> HeaderCompare.compare([:foo])

      assert new_hc == hc
    end

    test "it checks all the keys in the list" do
      valid_headers = [foo: "bar", baz: "bat"]
      request_headers = [a: "bar", baz: "cat"]

      hc = HeaderCompare.wrap(valid_headers, request_headers)
      new_hc = hc |> HeaderCompare.compare([:a, :b, :foo])

      assert new_hc == hc
    end

    test "it returns an error when the values are different" do
      valid_headers = [foo: "bar", baz: "bat"]
      request_headers = [foo: "bar", baz: "cat"]

      hc = HeaderCompare.wrap(valid_headers, request_headers)
      new_hc = hc |> HeaderCompare.compare([:baz])

      assert new_hc == :error
    end

    test "it can be chained" do
      valid_headers = [foo: "bar", baz: "bat", x: "y"]
      request_headers = [foo: "bar", baz: "cat", z: "y"]

      hc = HeaderCompare.wrap(valid_headers, request_headers)
      new_hc = hc
               |> HeaderCompare.compare([:foo])
               |> HeaderCompare.compare([:z, :x])

      assert new_hc == hc
    end

    test "it returns an error if any call in the chain is an error" do
      valid_headers = [foo: "bar", baz: "bat", x: "y"]
      request_headers = [foo: "bar", baz: "cat", z: "y"]

      hc = HeaderCompare.wrap(valid_headers, request_headers)
      new_hc = hc
               |> HeaderCompare.compare([:foo])
               |> HeaderCompare.compare([:baz])
               |> HeaderCompare.compare([:z, :x])

      assert new_hc == :error
    end
  end

  describe "to_boolean" do
    test "it is true when it is a tuple with :ok" do
      valid_headers = [foo: "bar"]
      request_headers = [foo: "bar"]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> HeaderCompare.compare([:foo])
      |> HeaderCompare.to_boolean()
      |> assert()
    end

    test "it is false otherwise" do
      valid_headers = [foo: "bar"]
      request_headers = [foo: "xyz"]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> HeaderCompare.compare([:foo])
      |> HeaderCompare.to_boolean()
      |> refute()
    end
  end
end
