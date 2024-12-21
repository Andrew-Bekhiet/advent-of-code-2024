defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "Part 1" do
    assert Day13.part1(true) == 480
    :timer.tc(Day13, :part1, [false]) |> inspect() |> IO.puts()
  end

  test "Part 2" do
    # assert Day13.part2(true) == 1930
    :timer.tc(Day13, :part2, [false]) |> inspect() |> IO.puts()
  end
end
