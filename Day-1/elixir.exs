defmodule Day1 do
  def part1(use_example) do
    {locations1, locations2} = parse_input(use_example)

    sorted1 = locations1 |> Enum.sort()
    sorted2 = locations2 |> Enum.sort()

    Enum.zip(sorted1, sorted2)
    |> Enum.map(fn {n1, n2} -> abs(n1 - n2) end)
    |> Enum.sum()
  end

  def part2(use_example) do
    {locations, list2} = parse_input(use_example)

    similarity_map =
      list2
      |> Enum.reduce(%{}, fn n, acc ->
        acc
        |> Map.update(n, 1, &(&1 + 1))
      end)

    IO.puts(inspect(similarity_map))

    locations
    |> Enum.map(fn n1 -> n1 * (similarity_map |> Access.get(n1, 0)) end)
    |> Enum.sum()
  end

  @spec parse_input(boolean) :: list({String.t(), list(pos_integer())})
  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], []}, fn line, {list1, list2} ->
      [s1, s2] = String.split(line, "   ", parts: 2)

      {num1, _} = Integer.parse(s1)
      {num2, _} = Integer.parse(s2)

      {[num1 | list1], [num2 | list2]}
    end)
  end
end
