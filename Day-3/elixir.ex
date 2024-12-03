defmodule Day3 do
  @mul_instruction_regex ~r/mul\((\d+),(\d+)\)/
  @conditional_group_regex ~r/do\(\)((?!don't)+)don't\(\)/

  @spec execute_line(String.t()) :: pos_integer()
  def execute_line(line) do
    Regex.scan(@mul_instruction_regex, line)
    |> Enum.reduce(
      0,
      fn [_, a, b], acc ->
        String.to_integer(a) * String.to_integer(b) + acc
      end
    )
  end

  def part1(use_example) do
    inputs = parse_input(use_example)

    inputs
    |> Enum.reduce(0, fn line, sum ->
      result = execute_line(line)

      sum + result
    end)
  end

  def part2(use_example) do
    inputs = parse_input(use_example)

    inputs
    |> Enum.join("")
    |> then(&("do()" <> &1 <> "don't()"))
    |> String.split("do()", trim: true)
    |> Enum.reduce(0, fn
      part, line_sum ->
        IO.puts(inspect(Regex.scan(~r/don't\(\)/, part), pretty: true))
        IO.puts(inspect(Regex.scan(~r/do\(\)/, part), pretty: true))
        IO.puts("")

        part_result =
          part
          |> String.split("don't()", parts: 2, trim: true)
          |> hd()
          |> execute_line()

        line_sum + part_result
    end)
  end

  @spec parse_input(boolean) :: list({String.t(), list(pos_integer())})
  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end
end
