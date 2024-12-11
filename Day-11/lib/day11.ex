defmodule Day11 do
  require Integer

  def blink(stones, memo) do
    stones
    |> Enum.flat_map_reduce(memo, fn
      0, memo ->
        {[1], memo}

      x, memo ->
        value =
          memo
          |> Map.get_lazy(x, fn ->
            digits = x |> Integer.digits()
            digits_count = digits |> length()

            if Integer.is_even(digits_count) do
              digits
              |> Enum.split(div(digits_count, 2))
              |> Tuple.to_list()
              |> Enum.map(&Integer.undigits/1)
            else
              [x * 2024]
            end
          end)

        {value, Map.put_new(memo, x, value)}
    end)
  end

  def part1(use_example) do
    stones = parse_input(use_example)

    1..25
    |> Enum.reduce({stones, Map.new()}, fn x, {stones, memo} ->
      {new_stones, new_memo} = blink(stones, memo)

      IO.puts("Blink #{x}")

      {new_stones, new_memo}
    end)
    |> elem(0)
    |> length()
  end

  def part2() do
    stones = parse_input(false)

    1..75
    |> Enum.reduce({stones, Map.new()}, fn x, {stones, memo} ->
      {new_stones, new_memo} = blink(stones, memo)

      IO.puts("Blink #{x}")

      {new_stones, new_memo}
    end)
    |> elem(0)
    |> length()
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.replace("\n", "")
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
