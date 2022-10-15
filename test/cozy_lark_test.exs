defmodule CozyLarkTest do
  use ExUnit.Case
  doctest CozyLark

  test "greets the world" do
    assert CozyLark.hello() == :world
  end
end
