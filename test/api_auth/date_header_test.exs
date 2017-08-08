defmodule ApiAuth.DateHeaderTest do
  use ExUnit.Case

  alias ApiAuth.DateHeader
  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare

  alias Calendar.DateTime.Format

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

  describe "compare" do
    test "it is true when the timestamps match" do
      timestamp = Format.httpdate(Calendar.DateTime.now_utc())
      valid_headers = [DATE: timestamp]
      request_headers = [HTTP_DATE: timestamp]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> assert()
    end

    test "it is false when the timestamps don't match" do
      time = Calendar.DateTime.now_utc()
      timestamp1 = Format.httpdate(time)
      timestamp2 = Format.httpdate(Calendar.DateTime.subtract!(time, 1))

      valid_headers = [DATE: timestamp1]
      request_headers = [HTTP_DATE: timestamp2]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> refute()
    end

    test "it is false if the timestamps are not times" do
      valid_headers = [DATE: "foo"]
      request_headers = [HTTP_DATE: "foo"]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> refute()
    end

    test "it is true if the timestamps are within 15 minutes from now" do
      time = Calendar.DateTime.subtract!(Calendar.DateTime.now_utc(), 800)
      timestamp = Format.httpdate(time)

      valid_headers = [DATE: timestamp]
      request_headers = [HTTP_DATE: timestamp]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> assert()
    end

    test "it is false if the timestamps are older than 15 minutes" do
      time = Calendar.DateTime.subtract!(Calendar.DateTime.now_utc(), 901)
      timestamp = Format.httpdate(time)

      valid_headers = [DATE: timestamp]
      request_headers = [HTTP_DATE: timestamp]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> refute()
    end

    test "it is false if the timestamps are in the future" do
      time = Calendar.DateTime.add!(Calendar.DateTime.now_utc(), 1)
      timestamp = Format.httpdate(time)

      valid_headers = [DATE: timestamp]
      request_headers = [HTTP_DATE: timestamp]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> refute()
    end
  end
end
