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
                |> Enum.map(fn char -> String.to_integer(char) end)
                |> List.to_tuple()
              ],
              String.length(line),
              1
            }

          line, {data, width, height} ->
            new_data =
              line
              |> String.graphemes()
              |> Enum.map(fn char -> String.to_integer(char) end)
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
end

defmodule Day10 do
  def find_trailheads(%Grid{width: width, height: height} = grid) do
    0..(height - 1)
    |> Enum.reduce([], fn y, acc ->
      0..(width - 1)
      |> Enum.reduce(acc, fn x, acc ->
        if grid |> Grid.at({x, y}) == 0 do
          [{x, y} | acc]
        else
          acc
        end
      end)
    end)
  end

  def calc_trail_score(_grid, []), do: []

  def calc_trail_score(%Grid{} = grid, [trail_head]) do
    trace_trail(grid, trail_head)
  end

  def calc_trail_score(%Grid{} = grid, [trail_head | trails]) do
    trace_trail(grid, trail_head) ++
      calc_trail_score(grid, trails)
  end

  def trace_trail(%Grid{} = grid, head, visited \\ MapSet.new()) do
    current = Grid.at(grid, head)

    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(fn dir -> next_location(head, dir) end)
    |> Enum.filter(fn next ->
      not MapSet.member?(visited, next) and
        Grid.has(grid, next) and
        Grid.at(grid, next) == current + 1
    end)
    |> Enum.reduce({[], MapSet.put(visited, head)}, fn next, {tails, visited} ->
      if Grid.at(grid, next) == 9 do
        {[next | tails], visited |> MapSet.put(next)}
      else
        {new_tails, new_visited} = trace_trail(grid, next, visited)

        {tails ++ new_tails, new_visited}
      end
    end)
  end

  def next_location({x, y}, {dx, dy}), do: {x + dx, y + dy}

  def part1(use_example) do
    grid = parse_input(use_example)

    trailheads = grid |> find_trailheads()

    trailheads
    |> Enum.map(&calc_trail_score(grid, [&1]))
    |> Enum.map(&(elem(&1, 0) |> Enum.count()))
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
