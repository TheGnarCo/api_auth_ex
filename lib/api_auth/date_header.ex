defmodule ApiAuth.DateHeader do
  @moduledoc false

  @keys [:DATE, :HTTP_DATE]
  @header_key :DATE
  @value_key :timestamp
  @allowed_skew 900
  @httpdate_format_string "%a, %d %b %Y %H:%M:%S GMT"
  @utc_timezone "Etc/UTC"

  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare

  alias Timex.Parse.DateTime.Parser

  def headers(hv) do
    hv |> HeaderValues.put_new(@keys, @header_key, @value_key, timestamp())
  end

  def compare(hc) do
    hc |> HeaderCompare.compare(@keys, &timestamp_compare/2)
  end

  @doc """
  Takes a DateTime and returns a string with the date-time in RFC 2616 format.
  This format is used in the HTTP protocol. Note that the date-time will always be "shifted" to UTC.
  """
  def httpdate(dt) do
    Calendar.strftime(dt, @httpdate_format_string)
  end

  @doc """
  Parses httpdates into Datetime structs
  iex> parse_httpdate("Sat, 06 Sep 2014 09:09:08 GMT")
  {:ok,
    %DateTime{
      year: 2014,
      month: 9,
      day: 6,
      hour: 9,
      minute: 9,
      second: 8,
      time_zone: "Etc/UTC",
      zone_abbr: "UTC",
      std_offset: 0,
      utc_offset: 0,
      microsecond: {0, 0}
    }
  }
  """
  def parse_httpdate(dt) do
    case Parser.parse(dt, @httpdate_format_string, :strftime) do
      {:ok, result} -> DateTime.from_naive(result, @utc_timezone)
      {:error, error_msg} -> {:error, error_msg}
    end
  end

  defp now do
    Timex.now(@utc_timezone)
  end

  # NOTE: Returns current datetime in RFC 2616 format.
  # Uses 'GMT' instead of 'UTC' for timezone.
  # e.g. "Mon, 23 Oct 2023 14:45:18 GMT"
  defp timestamp do
    now()
    |> httpdate
  end

  defp timestamp_compare(t1, t2) do
    t1 == t2 && timestamp_within_skew?(parse_httpdate(t1))
  end

  defp timestamp_within_skew?({:ok, time}) do
    case Timex.diff(now(), time, :second) do
      seconds when seconds < 0 -> false
      seconds when seconds == 0 -> true
      seconds when seconds <= @allowed_skew -> true
      _ -> false
    end
  end

  defp timestamp_within_skew?({:error, _}) do
    false
  end

  defp timestamp_within_skew?(_timestamp) do
    false
  end
end
