defmodule HuCovidTest do
  use ExUnit.Case
  doctest HuCovid

  test "greets the world" do
    assert HuCovid.hello() == :world
  end
end
