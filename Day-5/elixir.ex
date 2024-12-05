defmodule Day5 do
  def part1(use_example) do
    {ordering_rules, pages} = parse_input(use_example)

    IO.puts(inspect([ordering_rules: ordering_rules, pages: pages], pretty: true))

    pages
    |> Enum.filter(fn line ->
      ordering_rules_for_line =
        ordering_rules
        |> Enum.filter(fn {x, y} -> x in line and y in line end)
        |> Enum.reduce(%{}, fn {p1, p2}, acc ->
          Map.update(acc, p2, MapSet.new([p1]), fn value -> MapSet.put(value, p1) end)
        end)

      IO.puts(inspect([ordering_rules_for_line: ordering_rules_for_line], pretty: true))

      line
      |> Enum.reduce_while(MapSet.new(), fn
        page, acc ->
          previous_pages = Map.get(ordering_rules_for_line, page)

          IO.puts(
            inspect(
              [
                page: page,
                previous_pages: previous_pages,
                acc: acc
              ],
              pretty: true
            )
          )

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
    # |> tap(&IO.puts(inspect(Enum.map(&1, fn v -> [0 | v] end), binaries: :as_binaries)))
    |> Enum.map(fn pages ->
      count = Enum.count(pages)

      Enum.at(pages, div(count, 2))
    end)
    |> Enum.sum()
  end

  def part2(use_example) do
    input = parse_input(use_example)
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
