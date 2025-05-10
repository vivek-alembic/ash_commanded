defmodule AshCommandedTest do
  use ExUnit.Case
  doctest AshCommanded

  test "greets the world" do
    assert AshCommanded.hello() == :world
  end
end
