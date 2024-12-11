defmodule Day9 do
  def get_next(input, offset) do
    char = input |> Enum.at(offset)

    if char == "." do
      get_next(input, offset + 1)
    else
      {char, offset}
    end
  end

  def part1(use_example) do
    input =
      parse_input(use_example)
      |> Enum.reduce([], fn
        {"\n", _}, expanded ->
          expanded

        {char, i}, expanded when rem(i, 2) == 0 ->
          id = div(i, 2)

          List.duplicate(id, String.to_integer(char)) ++ expanded

        {char, _}, expanded ->
          List.duplicate(".", String.to_integer(char)) ++ expanded
      end)

    {reversed, length} = Enum.reduce(input, {[], 0}, fn e, {r, l} -> {[e | r], l + 1} end)

    reversed
    |> Enum.with_index()
    |> Enum.reduce_while({[], 0}, fn
      {_, i}, {result, j} when i + j == length ->
        {:halt, result}

      {".", _}, {result, j} ->
        {replacement, j} = get_next(input, j)

        {:cont, {[replacement | result], j + 1}}

      {char, _}, {result, j} ->
        {:cont, {[char | result], j}}
    end)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {id, i}, checksum -> id * i + checksum end)
  end

  def part2(use_example) do
    {reversed, _length} =
      parse_input(use_example)
      |> Enum.reduce({[], 0}, fn
        {"\n", _}, expanded ->
          expanded

        {char, i}, {expanded, length} ->
          id = if rem(i, 2) == 0, do: div(i, 2), else: "."
          size = String.to_integer(char)

          new_block = {id, size}

          if size == 0 do
            {expanded, length}
          else
            {[new_block | expanded], length + 1}
          end
      end)

    reversed
    |> Enum.filter(fn
      {id, size} -> id != "." and size > 0
    end)
    |> Enum.reduce(
      reversed |> Enum.reverse(),
      fn
        {_file_id, file_size} = file, result ->
          new_result =
            result
            |> Enum.flat_map_reduce(:not_found, fn
              {".", ^file_size}, :not_found ->
                {
                  [file],
                  :moved
                }

              {".", space_size}, :not_found when space_size > file_size ->
                {
                  [
                    file,
                    {".", space_size - file_size}
                  ],
                  :moved
                }

              ^file, :moved ->
                {
                  [{".", file_size}],
                  :moved
                }

              ^file, :not_found ->
                {
                  [file],
                  :not_moved
                }

              block, moved ->
                {
                  [block],
                  moved
                }
            end)
            |> elem(0)

          new_result
      end
    )
    |> Enum.flat_map(fn {id, count} -> List.duplicate(id, count) end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn
      {".", _i}, checksum -> checksum
      {id, i}, checksum -> id * i + checksum
    end)
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    input = filename |> File.read!()

    input
    |> String.graphemes()
    |> Enum.with_index()
  end
end
