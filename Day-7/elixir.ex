defmodule Day7 do
  def brute_force_result([number], _with_concat) do
    [number]
  end

  def brute_force_result([a, b], true) do
    [a * b, a + b, String.to_integer("#{b}#{a}")]
  end

  def brute_force_result([a, b], _) do
    [a * b, a + b]
  end

  def brute_force_result([head | rest], true) do
    brute_force_result(rest, true)
    |> Enum.reduce([], fn number, acc ->
      [head * number, head + number, String.to_integer("#{number}#{head}") | acc]
    end)
  end

  def brute_force_result([head | rest], _) do
    brute_force_result(rest, false)
    |> Enum.reduce([], fn number, acc ->
      [head * number, head + number | acc]
    end)
  end

  def part1(use_example) do
    input = parse_input(use_example)

    input
    |> Enum.filter(fn {result, numbers} ->
      solutions = numbers |> brute_force_result(false)

      solutions
      |> MapSet.new()
      |> MapSet.member?(result)
    end)
    |> Enum.reduce(0, fn {result, _}, acc ->
      acc + result
    end)
  end

  def part2(use_example) do
    input = parse_input(use_example)

    input
    |> Enum.filter(fn {result, numbers} ->
      solutions =
        numbers |> brute_force_result(true)

      solutions
      |> MapSet.new()
      |> MapSet.member?(result)
    end)
    |> Enum.reduce(0, fn {result, _}, acc ->
      acc + result
    end)
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [result, numbers] = String.split(line, ":", trim: true)

      {
        String.to_integer(result),
        numbers
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> Enum.reverse()
      }
    end)
  end
end
