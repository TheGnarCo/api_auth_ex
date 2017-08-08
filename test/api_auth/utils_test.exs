defmodule ApiAuth.UtilsTest do
  use ExUnit.Case

  alias ApiAuth.Utils

  describe "find" do
    test "it returns a tuple with :ok if it finds one of the keys" do
      headers = [hello: "world", foo: "bar"]

      found = headers
              |> Utils.find([:test, :foo])

      assert found == {:ok, "bar"}
    end

    test "it returns :error if it doesn't find one of the keys" do
      headers = [hello: "world", foo: "bar"]

      found = headers
              |> Utils.find([:other])

      assert found == :error
    end
  end

  describe "reject" do
    test "it returns the list without the given keys" do
      headers = [hello: "world", foo: "bar", baz: "xyz"]

      new_headers = headers
                    |> Utils.reject([:foo, :baz])

      assert new_headers == [hello: "world"]
    end
  end
end
