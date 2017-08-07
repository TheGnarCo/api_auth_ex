defmodule ApiAuth.DateHeaderTest do
  use ExUnit.Case

  alias ApiAuth.DateHeader
  alias ApiAuth.HeaderValues

  describe "headers" do
    test "it gets the value from the headers" do
      headers = [HTTP_DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
      value = headers
              |> HeaderValues.wrap()
              |> DateHeader.headers()
              |> HeaderValues.get(:timestamp)

      assert value == "Sat, 01 Jan 2000 00:00:00 GMT"
    end

    test "it defaults to the current time if not set" do
      headers = []
      value = headers
              |> HeaderValues.wrap()
              |> DateHeader.headers()
              |> HeaderValues.get(:timestamp)

      diff = Calendar.DateTime.now_utc()
             |> DateTime.diff(Calendar.DateTime.Parse.httpdate!(value), :second)

      assert diff == 0
    end

    test "it adds to the header if there is no key" do
      headers = []

      value = headers
              |> HeaderValues.wrap()
              |> DateHeader.headers()
              |> HeaderValues.unwrap()
              |> Keyword.fetch!(:DATE)

      diff = Calendar.DateTime.now_utc()
             |> DateTime.diff(Calendar.DateTime.Parse.httpdate!(value), :second)

      assert diff == 0
    end

    test "it does not change an existing header" do
      headers = [HTTP_DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
      new_headers = headers
                    |> HeaderValues.wrap()
                    |> DateHeader.headers()
                    |> HeaderValues.unwrap()

      assert new_headers == headers
    end
  end
end
