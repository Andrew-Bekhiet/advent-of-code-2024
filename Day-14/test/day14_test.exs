defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "Part 1" do
    assert Day14.part1(true) == 12
    :timer.tc(Day14, :part1, [false]) |> inspect() |> IO.puts()
  end

  # test "Part 2" do
  #   # assert Day14.part2(true) == 1930
  #   :timer.tc(Day14, :part2, [false]) |> inspect() |> IO.puts()
  # end
end
