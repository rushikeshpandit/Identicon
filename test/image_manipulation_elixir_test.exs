defmodule identiconTest do
  use ExUnit.Case
  doctest identicon

  test "greets the world" do
    assert identicon.hello() == :world
  end
end
