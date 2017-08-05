defmodule ApiAuth.DateHeader do
  @moduledoc false

  @keys       [:DATE, :HTTP_DATE]
  @header_key :DATE
  @value_key  :timestamp

  alias ApiAuth.HeaderValues

  def headers(hv) do
    hv |> HeaderValues.put_new(@keys, @header_key, @value_key, timestamp())
  end

  defp timestamp do
    Calendar.DateTime.now_utc()
    |> Calendar.DateTime.Format.httpdate
  end
end
