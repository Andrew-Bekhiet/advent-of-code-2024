defmodule Grid do
  @type t :: %__MODULE__{
          data: tuple(),
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
              [
                line
                |> String.graphemes()
                |> List.to_tuple()
              ],
              String.length(line),
              1
            }

          line, {data, width, height} ->
            new_data =
              line
              |> String.graphemes()
              |> List.to_tuple()

            {[new_data | data], width, height + 1}
        end
      )

    %Grid{
      data: data |> Enum.reverse() |> List.to_tuple(),
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
    data |> elem(y) |> elem(x)
  end

  def has(%Grid{}, {nil, _}), do: false
  def has(%Grid{}, {_, nil}), do: false

  def has(%Grid{width: width, height: height}, {x, y}),
    do: x >= 0 and x < width and y >= 0 and y < height

  def print_path(%Grid{} = grid, path) do
    for y <- 0..(grid.height - 1), reduce: "" do
      res ->
        for x <- 0..(grid.width - 1), reduce: res do
          res -> res <> if MapSet.member?(path, {x, y}), do: ".", else: Grid.at(grid, {x, y})
        end <> "\n"
    end
  end
end

defmodule Day12 do
  def get_point_neighbours({x, y}), do: [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}]

  def trace_group(%Grid{} = grid, {x, y}, seen) do
    current_group = Grid.at(grid, {x, y})

    get_point_neighbours({x, y})
    |> Enum.filter(&(Grid.at(grid, &1) == current_group and not MapSet.member?(seen, &1)))
    |> Enum.reduce({MapSet.new(), MapSet.put(seen, {x, y})}, fn point, {points, seen} ->
      {new_points, seen} = trace_group(grid, point, seen)

      # IO.puts("From #{inspect({x, y})} to #{inspect(point)} traced #{inspect(new_points)}")

      {points |> MapSet.union(new_points) |> MapSet.put(point), seen}
    end)
  end

  def group_plants(%Grid{width: width, height: height} = grid) do
    for y <- 0..(height - 1), x <- 0..(width - 1), reduce: {%{}, %{}, MapSet.new()} do
      {result, groups_shards, seen} ->
        IO.puts("#{x}, #{y}")

        if MapSet.member?(seen, {x, y}) do
          {result, groups_shards, seen}
        else
          {points, seen} = grid |> trace_group({x, y}, seen)

          points = MapSet.put(points, {x, y})

          group_name = grid |> Grid.at({x, y})

          {shard, groups_shards} =
            groups_shards
            |> Map.get_and_update(group_name, fn
              nil -> {1, 1}
              n -> {n + 1, n + 1}
            end)

          result = result |> Map.put({group_name, shard}, points)

          {result, groups_shards, seen}
        end
    end
  end

  def calc_perimeter(%Grid{} = grid, group, points) do
    for {x, y} <- points, reduce: 0 do
      perimeter ->
        point_perimeter =
          get_point_neighbours({x, y})
          |> Enum.filter(&(Grid.at(grid, &1) != group))
          |> length()

        perimeter + point_perimeter
    end
  end

  def calc_fencing_price(%Grid{} = grid, group, points) do
    area = points |> MapSet.size()
    perimeter = calc_perimeter(grid, group, points)

    area * perimeter
  end

  def part1(use_example) do
    grid = parse_input(use_example)

    grid
    |> group_plants()
    |> elem(0)
    |> Enum.filter(fn {_, points} -> not Enum.empty?(points) end)
    |> Enum.map(fn {{group, n}, points} ->
      calc_fencing_price(grid, group, points)
      # |> tap(fn price -> IO.puts("Price for #{group}#{n}: #{price}") end)
    end)
    |> Enum.sum()
  end

  # def part2(use_example) do
  # end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> Grid.parse()
  end
end
