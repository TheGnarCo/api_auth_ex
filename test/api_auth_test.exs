defmodule ApiAuthTest do
  use ExUnit.Case
  doctest ApiAuth

  test "calculates signature" do
    authorization = ApiAuth.authorization(
      "/",
      "1044",
      "123",
      hashed_content: "",
      time: time(),
      signature_hash: :sha,
    )

    assert authorization == "APIAuth 1044:49FglhLqXWuJqBu5SQOH4F8D1Og="
  end

  test "calculates signature with method, content type, and body" do
    authorization = ApiAuth.authorization(
      "/resource.xml?foo=bar&bar=foo",
      "1044",
      "123",
      method: "PUT",
      content_type: "text/plain",
      time: time(),
      content_hash: :md5,
      signature_hash: :sha256,
    )

    assert authorization == "APIAuth 1044:5JhErRhsIbN2+O595t/Rkax2n7w/YZ0f92BYgZFN5ds="
  end

  defp time do
    "Sat, 01 Jan 2000 00:00:00 GMT" |> Calendar.DateTime.Parse.httpdate!
  end
end
