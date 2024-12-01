defmodule Day1 do
  defp p1_pairwise([], []), do: 0

  defp p1_pairwise([n1 | rest1], [n2 | rest2]) do
    abs(n1 - n2) + p1_pairwise(rest1, rest2)
  end

  def part1(use_example) do
    {locations1, locations2} = parse_input(use_example)

    sorted1 = locations1 |> Enum.sort()
    sorted2 = locations2 |> Enum.sort()

    p1_pairwise(sorted1, sorted2)
  end

  defp p2_similarity([], _), do: 0

  defp p2_similarity([n | list], similarity_map) do
    n * Map.get(similarity_map, n, 0) + p2_similarity(list, similarity_map)
  end

  defp p2_similarity([n | list], %{} = similarity_map) do
    p2_similarity(list, similarity_map)
  end

  def part2(use_example) do
    {locations, list2} = parse_input(use_example)

    similarity_map = list2 |> Enum.frequencies()

    p2_similarity(locations, similarity_map)
  end

  @spec parse_input(boolean) :: list({String.t(), list(pos_integer())})
  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], []}, fn line, {list1, list2} ->
      {num1, rest} = Integer.parse(line)
      {num2, _} = rest |> String.trim() |> Integer.parse()

      {[num1 | list1], [num2 | list2]}
    end)
  end
end
