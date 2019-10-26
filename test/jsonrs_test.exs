defmodule JsonrsTest do
  use ExUnit.Case
  doctest Jsonrs

  test "encodes" do
    assert Jsonrs.encode!(%{"foo" => 5}) == "{\"foo\":5}"
  end

  test "decodes" do
    assert Jsonrs.decode!("{\"foo\":5}") == %{"foo" => 5}
  end
end
