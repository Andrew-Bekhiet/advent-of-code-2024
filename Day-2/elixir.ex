defmodule Day2 do
  defp are_diffs_valid?(diff, prev_diff) do
    abs(diff) <= 3 and abs(diff) >= 1 and
      (prev_diff == nil or prev_diff > 0 == diff > 0)
  end

  defp is_report_valid?([head | rest]) do
    rest
    |> Enum.reduce_while({head, nil}, fn
      level, {prev, prev_diff} ->
        diff = prev - level

        if abs(diff) <= 3 and abs(diff) >= 1 and
             (prev_diff == nil or prev_diff > 0 == diff > 0) do
          {:cont, {level, diff}}
        else
          {:halt, false}
        end
    end)
  end

  def part1(use_example) do
    reports = parse_input(use_example)

    reports
    |> Enum.count(fn [head | rest] ->
      rest
      |> Enum.reduce_while({head, nil}, fn
        level, {prev, prev_diff} ->
          diff = prev - level

          if abs(diff) <= 3 and abs(diff) >= 1 and
               (prev_diff == nil or prev_diff > 0 == diff > 0) do
            {:cont, {level, diff}}
          else
            {:halt, false}
          end
      end)
    end)
  end

  def part2(use_example) do
    reports = parse_input(use_example)

    reports
    |> Enum.count(fn report ->
      is_report_valid?(report) ||
        report
        |> Enum.with_index()
        |> Enum.any?(fn {_, i} ->
          report
          |> List.pop_at(i)
          |> elem(1)
          |> is_report_valid?()
        end)
    end)
  end

  @spec parse_input(boolean) :: list({String.t(), list(pos_integer())})
  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, " ", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end
end
