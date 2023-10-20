defmodule ApiAuth.ContentHashHeader do
  @moduledoc false

  @methods ["PUT", "POST"]
  @keys [
    :"X-APIAuth-Content-Hash",
    :"X-APIAUTH-CONTENT-HASH",
    :X_APIAUTH_CONTENT_HASH,
    :"Content-MD5",
    :"CONTENT-MD5",
    :CONTENT_MD5
  ]
  @header_key :"X-APIAuth-Content-Hash"
  @md5_header_key :"Content-MD5"
  @value_key :content_hash

  alias ApiAuth.HeaderValues
  alias ApiAuth.HeaderCompare

  def headers(hv, method, content, :md5) when method in @methods do
    content_hash = hash(:md5, content)

    hv |> HeaderValues.put_new(@keys, @md5_header_key, @value_key, content_hash)
  end

  def headers(hv, method, content, algorithm) when method in @methods do
    content_hash = hash(algorithm, content)

    hv |> HeaderValues.put_new(@keys, @header_key, @value_key, content_hash)
  end

  def headers(hv, _method, _content, _algorithm) do
    hv |> HeaderValues.copy(@keys, @value_key)
  end

  def override(hv, method, content, :md5) when method in @methods do
    content_hash = hash(:md5, content)

    hv |> HeaderValues.put(@keys, @md5_header_key, @value_key, content_hash)
  end

  def override(hv, method, content, algorithm) when method in @methods do
    content_hash = hash(algorithm, content)

    hv |> HeaderValues.put(@keys, @header_key, @value_key, content_hash)
  end

  def override(hv, _method, _content, _algorithm) do
    hv |> HeaderValues.copy(@keys, @value_key)
  end

  def compare(hc, method) when method in @methods do
    hc |> HeaderCompare.compare(@keys)
  end

  def compare(hc, _method) do
    hc
  end

  defp hash(algorithm, content) do
    algorithm
    |> :crypto.hash(content)
    |> Base.encode64()
  end
end
