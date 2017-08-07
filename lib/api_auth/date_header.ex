defmodule ApiAuth.DateHeader do
  @moduledoc false

  @keys       [:DATE, :HTTP_DATE]
  @header_key :DATE
  @value_key  :timestamp

  alias ApiAuth.HeaderValues
  alias Calendar.DateTime
  alias Calendar.DateTime.Format

  def headers(hv) do
    hv |> HeaderValues.put_new(@keys, @header_key, @value_key, timestamp())
  end

  defp timestamp do
    DateTime.now_utc()
    |> Format.httpdate
  end
end
