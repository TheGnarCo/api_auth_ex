defmodule ApiAuthTest do
  use ExUnit.Case
  doctest ApiAuth

  describe "headers" do
    test "adds missing headers and signs request" do
      headers = [DATE: "Sat, 01 Jan 2000 00:00:00 GMT"]
                |> ApiAuth.headers("/", "1044", "123", method: "POST")

      expected_headers = [
        Authorization: "APIAuth-HMAC-SHA256 1044:0GZ7kEF4vXa5wjyLYsddgW66Vp1i1i8jA+CO9+9umSI=",
        "X-APIAuth-Content-Hash": "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=",
        DATE: "Sat, 01 Jan 2000 00:00:00 GMT",
      ]

      assert headers == expected_headers
    end
  end
end
