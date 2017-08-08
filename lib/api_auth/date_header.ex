defmodule ApiAuth.DateHeader do
  @moduledoc false

  @keys         [:DATE, :HTTP_DATE]
  @header_key   :DATE
  @value_key    :timestamp
  @allowed_skew 900

  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare

  alias Calendar.DateTime
  alias Calendar.DateTime.Format
  alias Calendar.DateTime.Parse

  def headers(hv) do
    hv |> HeaderValues.put_new(@keys, @header_key, @value_key, timestamp())
  end

  def compare(hc) do
    hc |> HeaderCompare.compare(@keys, &timestamp_compare/2)
  end

  defp timestamp do
    DateTime.now_utc()
    |> Format.httpdate
  end

  defp timestamp_compare(t1, t2) do
    t1 == t2 && timestamp_within_skew?(Parse.httpdate(t1))
  end

  defp timestamp_within_skew?({:ok, time}) do
    now = DateTime.now_utc()

    case DateTime.diff(now, time) do
      {:ok, _, _, :same_time}   -> true
      {:ok, seconds, _, :after} -> seconds < @allowed_skew
      _                         -> false
    end
  end

  defp timestamp_within_skew?(_timestamp) do
    false
  end
end
