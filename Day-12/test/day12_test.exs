defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "Part 1" do
    assert Day12.part1(true) == 1930
    :timer.tc(Day12, :part1, [false]) |> inspect() |> IO.puts()
  end

  # test "Part 2" do
  #   assert Day12.part2(true) == 1930
  #   :timer.tc(Day12, :part2, [false]) |> inspect() |> IO.puts()
  # end
end
