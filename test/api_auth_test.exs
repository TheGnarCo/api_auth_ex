defmodule ApiAuthTest do
  use ExUnit.Case
  doctest ApiAuth

  describe "Date header" do
    test "adds the date to the header" do
      %{ "DATE" => date } = ApiAuth.headers("/", "1044", "123", time: time())

      assert date == "Sat, 01 Jan 2000 00:00:00 GMT"
    end

    test "uses the current time if none is given" do
      %{ "DATE" => date } = ApiAuth.headers("/", "1044", "123")

      diff = Calendar.DateTime.now_utc()
             |> DateTime.diff(Calendar.DateTime.Parse.httpdate!(date), :second)

      assert diff == 0
    end
  end

  describe "Content hash header" do
    test "there is no content hash when it is not a POST or PUSH" do
      headers = ApiAuth.headers("/", "1044", "123")

      assert headers["X-APIAuth-Content-Hash"] == nil
    end

    test "the content hash is calculated correctly" do
      %{ "X-APIAuth-Content-Hash" => hash } = ApiAuth.headers(
        "/",
        "1044",
        "123",
        method: "POST",
        content: "foo",
      )

      assert hash == "LCa0a2j/xo/5m0U8HTBBNBNCLXBkg7+g+YpeiGJm564="
    end

    test "the content hash header is different for md5" do
      %{ "Content-MD5" => hash } = ApiAuth.headers(
        "/",
        "1044",
        "123",
        method: "POST",
        content: "foo",
        content_algorithm: :md5,
      )

      assert hash == "rL0Y20zC+Fzt72VPzMSk2A=="
    end

    test "the content hash can be overwritten" do
      %{ "X-APIAuth-Content-Hash" => hash } = ApiAuth.headers(
        "/",
        "1044",
        "123",
        method: "POST",
        content: "foo",
        content_hash: "pre-computed hash",
      )

      assert hash == "pre-computed hash"
    end
  end

  describe "Authorization header" do
    test "calculates signature" do
      %{ "Authorization" => authorization } = ApiAuth.headers(
        "/",
        "1044",
        "123",
        time: time(),
        signature_algorithm: :sha,
      )

      assert authorization == "APIAuth 1044:49FglhLqXWuJqBu5SQOH4F8D1Og="
    end

    test "calculates signature with method, content type, and body" do
      %{ "Authorization" => authorization } = ApiAuth.headers(
        "/resource.xml?foo=bar&bar=foo",
        "1044",
        "123",
        method: "PUT",
        content_type: "text/plain",
        time: time(),
        content_algorithm: :md5,
      )

      assert authorization == "APIAuth-HMAC-SHA256 1044:5JhErRhsIbN2+O595t/Rkax2n7w/YZ0f92BYgZFN5ds="
    end
  end

  defp time do
    "Sat, 01 Jan 2000 00:00:00 GMT" |> Calendar.DateTime.Parse.httpdate!
  end
end
