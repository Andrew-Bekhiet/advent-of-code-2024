defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "Part 1" do
    assert Day11.part1(true) == 55312
    :timer.tc(Day11, :part1, [false]) |> inspect() |> IO.puts()
  end

  test "Part 2" do
    :timer.tc(Day11, :part2, []) |> inspect() |> IO.puts()
  end
end
