defmodule ChartsTest do
  use ExUnit.Case, async: true
  doctest Charts

  test "greets the world" do
    assert Charts.hello() == :world
  end
end
