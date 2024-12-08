defmodule Grid do
  @type t :: %__MODULE__{
          data: list(list(String.t())),
          width: integer(),
          height: integer()
        }
  defstruct [:data, :width, :height]

  def parse(input) do
    {data, width, height} =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce(
        {nil, 0, 0},
        fn
          line, {nil, 0, 0} ->
            {
              [line |> String.graphemes()],
              String.length(line),
              1
            }

          line, {data, width, height} ->
            new_data = line |> String.graphemes()

            {[new_data | data], width, height + 1}
        end
      )

    %Grid{
      data: data |> Enum.reverse(),
      width: width,
      height: height
    }
  end

  def at(%Grid{}, {nil, _}), do: nil
  def at(%Grid{}, {_, nil}), do: nil

  def at(%Grid{width: width, height: height}, {x, y})
      when x < 0 or x >= width or y < 0 or y >= height,
      do: nil

  def at(%Grid{data: data}, {x, y}) do
    data |> Enum.at(y) |> Enum.at(x)
  end

  def has(%Grid{}, {nil, _}), do: nil
  def has(%Grid{}, {_, nil}), do: nil

  def has(%Grid{width: width, height: height}, {x, y}),
    do: x >= 0 and x < width and y >= 0 and y < height
end

defmodule Day8 do
  def group_antenas(%Grid{data: data}) do
    data
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {".", _x}, acc ->
          acc

        {char, x}, acc ->
          acc
          |> Map.update(
            char,
            [{x, y}],
            fn value -> [{x, y} | value] end
          )
      end)
    end)
  end

  def negate_loc({x, y}), do: {-x, -y}

  def diff_locations({x1, y1}, {x2, y2}), do: {x2 - x1, y2 - y1}

  def add_locations({x, y}, {diff_x, diff_y}), do: {x + diff_x, y + diff_y}

  def possible_combinations([], _grid, _part2), do: MapSet.new()

  def possible_combinations([_], _grid, _part2), do: MapSet.new()

  def possible_combinations([loc1, loc2], %Grid{} = grid, false) do
    difference = diff_locations(loc1, loc2)

    [
      add_locations(loc2, difference),
      add_locations(loc1, negate_loc(difference))
    ]
    |> Enum.filter(&Grid.has(grid, &1))
    |> MapSet.new()
  end

  def possible_combinations([loc1, loc2], %Grid{} = grid, true) do
    IO.puts("Combining #{inspect(loc1)} with #{inspect(loc2)}")

    difference = diff_locations(loc1, loc2)

    result = add_locations(loc2, difference)

    if grid |> Grid.has(result) do
      possible_combinations([loc2, result], grid, true)
      |> MapSet.put(result)
      |> MapSet.put(loc1)
      |> MapSet.put(loc2)
    else
      MapSet.new()
    end
  end

  def possible_combinations([loc1, loc2], %Grid{} = grid, nil) do
    IO.puts("-Combining #{inspect(loc1)} with #{inspect(loc2)}")

    difference = negate_loc(diff_locations(loc1, loc2))

    result = add_locations(loc2, difference)

    if grid |> Grid.has(result) do
      possible_combinations([loc2, result], grid, true)
      |> MapSet.put(result)
      |> MapSet.put(loc1)
      |> MapSet.put(loc2)
    else
      MapSet.new()
    end
  end

  def possible_combinations([head | antenas_locations], %Grid{} = grid, false) do
    antenas_locations
    |> Enum.reduce(MapSet.new(), fn loc, acc ->
      [head, loc]
      |> possible_combinations(grid, false)
      |> MapSet.union(acc)
    end)
    |> MapSet.union(antenas_locations |> possible_combinations(grid, false))
  end

  def possible_combinations([head | antenas_locations], %Grid{} = grid, _) do
    IO.puts("Trying #{inspect(head)} with #{inspect(antenas_locations)}")

    antenas_locations
    |> Enum.reduce(MapSet.new(), fn loc, acc ->
      IO.puts("  Trying #{inspect(head)} with #{inspect(loc)}")

      [head, loc]
      |> possible_combinations(grid, true)
      |> MapSet.union([loc, head] |> possible_combinations(grid, true))
      |> MapSet.union(acc)
    end)
    |> MapSet.union(antenas_locations |> possible_combinations(grid, true))
    |> MapSet.union(antenas_locations |> possible_combinations(grid, nil))
  end

  def part1(use_example) do
    grid = parse_input(use_example)

    grid
    |> group_antenas()
    |> Map.values()
    |> Enum.reduce(MapSet.new(), fn antenas, acc ->
      antenas
      |> possible_combinations(grid, false)
      |> MapSet.difference(MapSet.new(antenas))
      |> MapSet.union(acc)
    end)
    |> MapSet.size()
  end

  def part2(use_example) do
    grid = parse_input(use_example)

    grid
    |> group_antenas()
    |> Map.values()
    |> Enum.reduce(MapSet.new(), fn antenas, acc ->
      antenas
      |> possible_combinations(grid, true)
      |> MapSet.union(MapSet.new(antenas))
      |> MapSet.union(acc)
    end)
    |> tap(&IO.puts(inspect(&1)))
    |> MapSet.size()
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> Grid.parse()
  end
end
