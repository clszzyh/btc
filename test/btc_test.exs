defmodule BtcTest do
  use ExUnit.Case
  doctest Btc

  test "greets the world" do
    assert Btc.hello() == :world
  end
end
