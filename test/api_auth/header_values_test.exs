defmodule ApiAuth.HeaderValuesTest do
  use ExUnit.Case

  alias ApiAuth.HeaderValues

  describe "wrap" do
    test "it wraps headers in a header values structure" do
      header_values = [hello: "world", a: 1]
                      |> HeaderValues.wrap

      assert header_values == { [hello: "world", a: 1], %{} }
    end
  end

  describe "unwrap" do
    test "it returns the header from a header values structure" do
      headers = { [hello: "world", a: 1], %{} }
                |> HeaderValues.unwrap

      assert headers == [hello: "world", a: 1]
    end

    test "calling wrap and unwrap returns the original list" do
      list = [hello: "world", a: 1]
      new_list = list |> HeaderValues.wrap |> HeaderValues.unwrap

      assert list == new_list
    end
  end

  describe "transform" do
    test "it transforms the values without changing the headers" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      new_header_values = header_values
                          |> HeaderValues.transform(:a, nil, &(&1 + 1))

      assert new_header_values == { [hello: "world", a: 1], %{ a: 2 } }
    end

    test "it uses the default if there is no matching value" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      new_header_values = header_values
                          |> HeaderValues.transform(:b, 15, &(&1 + 1))

      assert new_header_values == { [hello: "world", a: 1], %{ a: 1, b: 15 } }
    end
  end

  describe "get" do
    test "it gets the value" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      value = HeaderValues.get(header_values, :a)

      assert value == 1
    end

    test "it returns the empty string if there is no match" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      value = HeaderValues.get(header_values, :hello)

      assert value == ""
    end

    test "it returns the default if there is no match and a default is passed in" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      value = HeaderValues.get(header_values, :hello, "default")

      assert value == "default"
    end
  end

  describe "copy" do
    test "there is no matching header so it uses the default value" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      new_header_values = header_values
                          |> HeaderValues.copy([:Other], :other, "foo")

      assert new_header_values == { [hello: "world", a: 1], %{ a: 1, other: "foo" } }
    end

    test "it uses the value from the header" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      new_header_values = header_values
                          |> HeaderValues.copy([:Other, :hello], :other, "foo")

      assert new_header_values == { [hello: "world", a: 1], %{ a: 1, other: "world" } }
    end
  end

  describe "put" do
    test "there is no matching header so it uses the default value" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      new_header_values = header_values
                          |> HeaderValues.put([:Other], :Other, :other, "foo")

      assert new_header_values == { [Other: "foo", hello: "world", a: 1], %{ a: 1, other: "foo" } }
    end

    test "it uses the default value" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      new_header_values = header_values
                          |> HeaderValues.put([:Other, :hello], :Other, :other, "foo")

      assert new_header_values == { [Other: "foo", a: 1], %{ a: 1, other: "foo" } }
    end
  end

  describe "put_new" do
    test "there is no matching header so it uses the default value" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      new_header_values = header_values
                          |> HeaderValues.put_new([:Other], :Other, :other, "foo")

      assert new_header_values == { [Other: "foo", hello: "world", a: 1], %{ a: 1, other: "foo" } }
    end

    test "it uses the value from the header" do
      header_values = { [hello: "world", a: 1], %{ a: 1 } }
      new_header_values = header_values
                          |> HeaderValues.put_new([:Other, :hello], :Other, :other, "foo")

      assert new_header_values == { [hello: "world", a: 1], %{ a: 1, other: "world" } }
    end
  end
end
