defmodule Day7 do
  defp concat(b, a) do
    String.to_integer("#{b}#{a}")
  end

  defp brute_force_result([number], _target, _with_concat) do
    [number]
  end

  defp brute_force_result([a, b], target, with_concat) do
    x = a * b
    y = a + b
    z = if with_concat, do: concat(b, a), else: nil

    cond do
      with_concat -> [x, y, z]
      true -> [x, y]
    end
  end

  defp brute_force_result([head | rest], target, with_concat) do
    solutions = brute_force_result(rest, target, with_concat)

    solutions
    |> Enum.reduce([], fn number, acc ->
      x = head * number
      y = head + number
      z = if with_concat, do: concat(number, head), else: nil

      cond do
        with_concat -> [x, y, z | acc]
        true -> [x, y | acc]
      end
    end)
  end

  def part1(use_example) do
    input = parse_input(use_example)

    input
    |> Enum.filter(fn {result, numbers} ->
      solutions = numbers |> brute_force_result(result, false)

      solutions |> Enum.member?(result)
    end)
    |> Enum.reduce(0, fn {result, _}, acc ->
      acc + result
    end)
  end

  def part2(use_example) do
    input = parse_input(use_example)

    input
    |> Enum.filter(fn {result, numbers} ->
      solutions = numbers |> brute_force_result(result, true)

      solutions |> Enum.member?(result)
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
