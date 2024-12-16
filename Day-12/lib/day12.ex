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
  @spec get_loc_neighbours({number(), number()}) :: [{number(), number()}, ...]
  def get_loc_neighbours({x, y}), do: [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}]

  @spec trace_group(Grid.t(), {number(), number()}, MapSet.t()) :: {MapSet.t(), MapSet.t()}
  def trace_group(%Grid{} = grid, {x, y}, seen) do
    current_group = Grid.at(grid, {x, y})

    get_loc_neighbours({x, y})
    |> Enum.filter(&(Grid.at(grid, &1) == current_group and not MapSet.member?(seen, &1)))
    |> Enum.reduce({MapSet.new({x, y}), MapSet.put(seen, {x, y})}, fn loc, {locs, seen} ->
      {new_locs, seen} = trace_group(grid, loc, seen)

      # IO.puts("From #{inspect({x, y})} to #{inspect(loc)} traced #{inspect(new_locs)}")

      {locs |> MapSet.union(new_locs) |> MapSet.put(loc), seen}
    end)
  end

  def trace_group_from(%Grid{} = grid, group_name, loc, seen) do
    {locs, seen} =
      loc
      |> get_loc_neighbours()
      |> Enum.reduce(
        {[], seen |> MapSet.put(loc)},
        fn loc, {locs, seen} ->
          cond do
            group_name == grid |> Grid.at(loc) and not MapSet.member?(seen, loc) ->
              {[loc | locs], seen |> MapSet.put(loc)}

            # true || MapSet.member?(seen, loc) ->
            true ->
              {locs, seen}
          end
        end
      )

    locs
    |> Enum.reduce(
      {locs, seen},
      fn loc, {locs, seen} ->
        {new_locs, seen} = trace_group_from(grid, group_name, loc, seen)

        {new_locs ++ locs, seen}
      end
    )
  end

  def group_plants(%Grid{width: width, height: height} = grid) do
    for y <- 0..(height - 1), x <- 0..(width - 1), reduce: {[], MapSet.new()} do
      {shards, seen} ->
        loc = {x, y}

        if MapSet.member?(seen, loc) do
          {shards, seen}
        else
          group_name = grid |> Grid.at(loc)

          {locs, seen} = trace_group_from(grid, group_name, loc, seen)

          {[{group_name, [loc | locs] |> MapSet.new()} | shards], seen}
        end
    end
  end

  def calc_perimeter(%Grid{} = grid, group, locs) do
    for {x, y} <- locs, reduce: 0 do
      perimeter ->
        loc_perimeter =
          get_loc_neighbours({x, y})
          |> Enum.filter(&(Grid.at(grid, &1) != group))
          |> length()

        perimeter + loc_perimeter
    end
  end

  def calc_sides(%Grid{} = grid, group, locs) do
    for {x, y} <- locs, reduce: 0 do
      sides ->
        loc_perimeter =
          get_loc_neighbours({x, y})
          |> Enum.filter(&(Grid.at(grid, &1) != group))
          |> length()

        sides + loc_perimeter
    end
  end

  def calc_fencing_price(%Grid{} = grid, group, locs) do
    area = locs |> MapSet.size()
    perimeter = calc_perimeter(grid, group, locs)

    area * perimeter
  end

  def calc_discounted_fencing_price(%Grid{} = grid, group, locs) do
    area = locs |> MapSet.size()
    perimeter = calc_sides(grid, group, locs)

    area * perimeter
  end

  def part1(use_example) do
    grid = parse_input(use_example)

    grid
    |> group_plants()
    |> tap(fn shards -> IO.puts("Shards: #{inspect(shards)}") end)
    |> elem(0)
    |> Enum.filter(fn {_, locs} -> not Enum.empty?(locs) end)
    |> Enum.map(fn {group, locs} ->
      calc_fencing_price(grid, group, locs)
      # |> tap(fn price -> IO.puts("Price for #{group}#{n}: #{price}") end)
    end)
    |> Enum.sum()
  end

  def part2(use_example) do
    grid = parse_input(use_example)

    grid
    |> group_plants()
    |> elem(0)
    |> Enum.filter(fn {_, locs} -> not Enum.empty?(locs) end)
    |> Enum.map(fn {{group, _n}, locs} ->
      calc_discounted_fencing_price(grid, group, locs)
      # |> tap(fn price -> IO.puts("Price for #{group}#{n}: #{price}") end)
    end)
    |> Enum.sum()
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> Grid.parse()
  end
end
