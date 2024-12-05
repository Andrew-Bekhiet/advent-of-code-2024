defmodule Day5 do
  def part1(use_example) do
    {ordering_rules, pages} = parse_input(use_example)

    pages
    |> Enum.filter(fn line ->
      ordering_rules_for_line =
        ordering_rules
        |> Enum.filter(fn {x, y} -> x in line and y in line end)
        |> Enum.reduce(%{}, fn {p1, p2}, acc ->
          acc |> Map.update(p2, MapSet.new([p1]), &MapSet.put(&1, p1))
        end)

      line
      |> Enum.reduce_while(MapSet.new(), fn
        page, acc ->
          previous_pages = Map.get(ordering_rules_for_line, page)

          cond do
            MapSet.size(acc) > 0 and
                (previous_pages == nil or MapSet.subset?(previous_pages, acc)) ->
              {:cont, MapSet.put(acc, page)}

            MapSet.size(acc) == 0 and
                (previous_pages == nil or
                   MapSet.disjoint?(previous_pages, line |> tl() |> MapSet.new())) ->
              {:cont, MapSet.put(acc, page)}

            true ->
              {:halt, false}
          end
      end)
    end)
    |> Enum.map(fn pages ->
      count = Enum.count(pages)

      Enum.at(pages, div(count, 2))
    end)
    |> Enum.sum()
  end

  def part2(use_example) do
    {ordering_rules, pages} = parse_input(use_example)

    pages
    |> Enum.map(fn line ->
      ordering_rules_for_line =
        ordering_rules
        |> Enum.filter(fn {x, y} -> x in line and y in line end)
        |> Enum.reduce(%{}, fn {p1, p2}, acc ->
          acc |> Map.update(p2, [p1], &[p1 | &1])
        end)

      sorted =
        line
        |> Enum.sort(fn a, b ->
          not (ordering_rules_for_line |> Map.get(a, []) |> Enum.member?(b))
        end)

      if line == sorted do
        0
      else
        Enum.at(sorted, div(Enum.count(sorted), 2))
      end
    end)
    |> Enum.sum()
  end

  @spec parse_input(boolean) :: {[{integer(), integer()}], [[integer()]]}
  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    [ordering_rules, pages] =
      filename
      |> File.read!()
      |> String.split("\n\n", trim: true)

    parsed_ordering_rules =
      ordering_rules =
      String.split(ordering_rules, "\n", trim: true)
      |> Enum.reduce([], fn line, acc ->
        [p1, p2] = String.split(line, "|")

        p1 = String.to_integer(p1)
        p2 = String.to_integer(p2)

        [{p1, p2} | acc]
      end)

    parsed_pages =
      String.split(pages, "\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

    {parsed_ordering_rules, parsed_pages}
  end
end
