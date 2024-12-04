defmodule Grid do
  @type t :: %__MODULE__{
          data: list(String.t())
        }
  defstruct [:data]

  def at(grid, {x, y}) when is_nil(x) or is_nil(y), do: nil

  def at(grid, {x, y}) do
    if grid |> has({x, y}) do
      grid.data
      |> Enum.at(y)
      |> case do
        nil -> nil
        line -> String.at(line, x)
      end
    else
      nil
    end
  end

  def has(grid, {x, y}) when is_nil(x) or is_nil(y), do: false

  def has(grid, {x, y}) do
    x >= 0 and x < length(grid.data) and y >= 0 and y < String.length(grid.data |> Enum.at(0))
  end
end

defmodule Day4 do
  defp find_all_words_in(grid, y, word) do
    grid.data
    |> Enum.at(y)
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {char, x}, acc ->
      positive_x =
        grid |> find_all_words_in_using(y, x, word, :right)

      negative_x =
        grid |> find_all_words_in_using(y, x, word, :left)

      positive_y =
        grid |> find_all_words_in_using(y, x, word, :down)

      negative_y = grid |> find_all_words_in_using(y, x, word, :up)

      positive_diagonl1 =
        grid |> find_all_words_in_using(y, x, word, :up_right)

      negative_diagonl1 =
        grid |> find_all_words_in_using(y, x, word, :down_left)

      positive_diagonl2 =
        grid |> find_all_words_in_using(y, x, word, :down_right)

      negative_diagonl2 =
        grid |> find_all_words_in_using(y, x, word, :up_left)

      positive_x
      |> MapSet.union(negative_x)
      |> MapSet.union(positive_y)
      |> MapSet.union(negative_y)
      |> MapSet.union(positive_diagonl1)
      |> MapSet.union(negative_diagonl1)
      |> MapSet.union(positive_diagonl2)
      |> MapSet.union(negative_diagonl2)
      |> MapSet.union(acc)
    end)
  end

  defp find_all_x_words_in(grid, y) do
    grid.data
    |> Enum.at(y)
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {char, x}, acc ->
      cond do
        grid |> Grid.at({x, y}) != "A" ->
          acc

        grid |> Grid.at({x + 1, y + 1}) == "M" and grid |> Grid.at({x - 1, y - 1}) == "S" and
            ((grid |> Grid.at({x - 1, y + 1}) == "M" and grid |> Grid.at({x + 1, y - 1}) == "S") or
               (grid |> Grid.at({x - 1, y + 1}) == "S" and grid |> Grid.at({x + 1, y - 1}) == "M")) ->
          MapSet.put(acc, {x, y})

        grid |> Grid.at({x + 1, y + 1}) == "S" and grid |> Grid.at({x - 1, y - 1}) == "M" and
            ((grid |> Grid.at({x - 1, y + 1}) == "M" and grid |> Grid.at({x + 1, y - 1}) == "S") or
               (grid |> Grid.at({x - 1, y + 1}) == "S" and grid |> Grid.at({x + 1, y - 1}) == "M")) ->
          MapSet.put(acc, {x, y})

        true ->
          acc
      end
    end)
  end

  defp find_all_words_in_using(grid, y, x, word, dir) do
    word
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce_while(MapSet.new(), fn {char, i}, acc ->
      pos =
        case dir do
          :up -> {x, y - i}
          :down -> {x, y + i}
          :left -> {x - i, y}
          :right -> {x + i, y}
          :up_right -> {x + i, y - i}
          :down_right -> {x + i, y + i}
          :up_left -> {x - i, y - i}
          :down_left -> {x - i, y + i}
        end

      if char == grid |> Grid.at(pos) do
        {:cont, MapSet.put(acc, {x, y, dir})}
      else
        {:halt, MapSet.new()}
      end
    end)
  end

  def part1(use_example) do
    grid = parse_input(use_example)

    grid.data
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, coords ->
      grid
      |> find_all_words_in(y, "XMAS")
      |> MapSet.union(coords)
    end)
    |> tap(&IO.puts(MapSet.size(&1)))
  end

  def part2(use_example) do
    grid = parse_input(use_example)

    grid.data
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, coords ->
      grid
      |> find_all_x_words_in(y)
      |> MapSet.union(coords)
    end)
    |> tap(&IO.puts(MapSet.size(&1)))
  end

  @spec parse_input(boolean) :: list({String.t(), list(pos_integer())})
  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> then(&%Grid{data: &1})
  end
end
