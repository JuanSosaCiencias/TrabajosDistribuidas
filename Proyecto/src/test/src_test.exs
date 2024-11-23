defmodule SrcTest do
  use ExUnit.Case
  doctest Src

  test "greets the world" do
    assert Src.hello() == :world
  end
end
