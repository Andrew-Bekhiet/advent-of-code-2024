defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "Part 1" do
    assert Day10.part1(true) == 36
    :timer.tc(Day10, :part1, [false]) |> inspect() |> IO.puts()
  end

  test "Part 2" do
    assert Day10.part2(true) == 81
    :timer.tc(Day10, :part2, [false]) |> inspect() |> IO.puts()
  end
end
