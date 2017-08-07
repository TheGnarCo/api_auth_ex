defmodule ApiAuth.ContentTypeHeader do
  @moduledoc false

  @keys      [:"Content-Type", :"CONTENT-TYPE", :"CONTENT_TYPE", :"HTTP_CONTENT_TYPE"]
  @value_key :content_type

  alias ApiAuth.HeaderValues

  def headers(hv) do
    HeaderValues.copy(hv, @keys, @value_key)
  end
end
