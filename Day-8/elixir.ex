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

  def has(%Grid{}, {nil, _}), do: false
  def has(%Grid{}, {_, nil}), do: false

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

  def get_dir({x1, y1}, {x2, y2}), do: {x2 - x1, y2 - y1}

  def add_dir({x, y}, {diff_x, diff_y}), do: {x + diff_x, y + diff_y}

  def get_all_line_points(initial, dir, grid) do
    next = add_dir(initial, dir)

    if grid |> Grid.has(next) do
      get_all_line_points(next, dir, grid)
      |> MapSet.put(next)
    else
      MapSet.new([])
    end
  end

  def find_antinodes([], _grid, _all), do: MapSet.new()

  def find_antinodes([_], _grid, _all), do: MapSet.new()

  def find_antinodes([loc1, loc2], %Grid{} = grid, false = _all) do
    [
      # in direction of loc2 -> loc1
      add_dir(loc2, get_dir(loc1, loc2)),
      # in direction of loc1 -> loc2
      add_dir(loc1, get_dir(loc2, loc1))
    ]
    |> Enum.filter(&Grid.has(grid, &1))
    |> MapSet.new()
  end

  def find_antinodes([loc1, loc2], %Grid{} = grid, true = _all) do
    dir1 = get_dir(loc1, loc2)
    dir2 = get_dir(loc2, loc1)

    get_all_line_points(loc2, dir1, grid)
    |> MapSet.union(get_all_line_points(loc1, dir2, grid))
  end

  def find_antinodes([head | antenas_locations], %Grid{} = grid, all) do
    antenas_locations
    |> Enum.reduce(MapSet.new(), fn loc, acc ->
      [head, loc]
      |> find_antinodes(grid, all)
      |> MapSet.union(acc)
    end)
    |> MapSet.union(antenas_locations |> find_antinodes(grid, all))
  end

  def part1(use_example) do
    grid = parse_input(use_example)

    grid
    |> group_antenas()
    |> Map.values()
    |> Enum.reduce(MapSet.new(), fn antenas, acc ->
      antenas
      |> find_antinodes(grid, false)
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
      |> find_antinodes(grid, true)
      |> MapSet.union(MapSet.new(antenas))
      |> MapSet.union(acc)
    end)
    |> MapSet.size()
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> Grid.parse()
  end
end
