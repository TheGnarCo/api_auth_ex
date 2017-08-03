defmodule ApiAuthTest do
  use ExUnit.Case
  doctest ApiAuth

  test "greets the world" do
    assert ApiAuth.hello() == :world
  end
end
