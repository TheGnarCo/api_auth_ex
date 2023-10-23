defmodule ApiAuth.DateHeaderTest do
  use ExUnit.Case

  alias ApiAuth.DateHeader
  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare

  describe "headers" do
    test "it gets the value from the headers" do
      headers = [HTTP_DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]

      value =
        headers
        |> HeaderValues.wrap()
        |> DateHeader.headers()
        |> HeaderValues.get(:timestamp)

      assert value == "Sat, 01 Jan 2000 00:00:00 GMT"
    end

    test "it defaults to the current time if not set" do
      headers = []

      value =
        headers
        |> HeaderValues.wrap()
        |> DateHeader.headers()
        |> HeaderValues.get(:timestamp)

      {:ok, parsed} = DateHeader.parse_httpdate(value)
      diff = Timex.diff(Timex.now(:utc), parsed, :second)

      assert diff == 0
    end

    test "it adds to the header if there is no key" do
      headers = []

      value =
        headers
        |> HeaderValues.wrap()
        |> DateHeader.headers()
        |> HeaderValues.unwrap()
        |> Keyword.fetch!(:DATE)

      {:ok, parsed} = DateHeader.parse_httpdate(value)
      diff = Timex.diff(Timex.now(:utc), parsed, :second)

      assert diff == 0
    end

    test "it does not change an existing header" do
      headers = [HTTP_DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]

      new_headers =
        headers
        |> HeaderValues.wrap()
        |> DateHeader.headers()
        |> HeaderValues.unwrap()

      assert new_headers == headers
    end
  end

  describe "compare" do
    test "it is true when the timestamps match" do
      timestamp = DateHeader.httpdate(Timex.now(:utc))
      valid_headers = [DATE: timestamp]
      request_headers = [HTTP_DATE: timestamp]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> assert()
    end

    test "it is false when the timestamps don't match" do
      now = Timex.now(:utc)
      timestamp1 = DateHeader.httpdate(now)
      past = Timex.shift(now, seconds: -1)
      timestamp2 = DateHeader.httpdate(past)

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
      time = Timex.shift(Timex.now(:utc), seconds: -800)
      timestamp = DateHeader.httpdate(time)
      valid_headers = [DATE: timestamp]
      request_headers = [HTTP_DATE: timestamp]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> assert()
    end

    test "it is false if the timestamps are older than 15 minutes" do
      time = Timex.shift(Timex.now(:utc), seconds: -901)
      timestamp = DateHeader.httpdate(time)

      valid_headers = [DATE: timestamp]
      request_headers = [HTTP_DATE: timestamp]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> refute()
    end

    test "it is false if the timestamps are in the future" do
      time = Timex.shift(Timex.now(:utc), seconds: 7)
      timestamp = DateHeader.httpdate(time)
      valid_headers = [DATE: timestamp]
      request_headers = [HTTP_DATE: timestamp]

      valid_headers
      |> HeaderCompare.wrap(request_headers)
      |> DateHeader.compare()
      |> HeaderCompare.to_boolean()
      |> refute()
    end
  end

  describe "httpdate" do
    test "it formats the datetime object correctly" do
      date = DateTime.new!(~D[2023-10-31], ~T[12:34:16], "Etc/UTC")

      assert DateHeader.httpdate(date) == "Tue, 31 Oct 2023 12:34:16 GMT"
    end
  end

  describe "parse_httpdate" do
    test "it parses httpdate into datetime object" do
      {:ok, result} = DateHeader.parse_httpdate("Tue, 31 Oct 2023 04:59:03 GMT")

      assert result == %DateTime{
               year: 2023,
               month: 10,
               day: 31,
               hour: 4,
               minute: 59,
               second: 3,
               time_zone: "Etc/UTC",
               zone_abbr: "UTC",
               std_offset: 0,
               utc_offset: 0,
               microsecond: {0, 0}
             }
    end
  end
end
