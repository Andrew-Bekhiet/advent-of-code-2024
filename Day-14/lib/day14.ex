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
          res -> res <> if MapSet.member?(path, {x, y}), do: "#", else: Grid.at(grid, {x, y})
        end <> "\n"
    end
  end
end

defmodule Day14 do
  @line_regex ~r/^p=(?<px>[^,]+),(?<py>[^,]+) v=(?<vx>[^,]+),(?<vy>[^,]+)$/

  def scale_vector({dx, dy}, scalar), do: {dx * scalar, dy * scalar}
  def add_vectors({dx1, dy1}, {dx2, dy2}), do: {dx1 + dx2, dy1 + dy2}

  def maybe_align({x, y}, width, height) when x >= 0 and x <= width and y >= 0 and y <= height,
    do: {x, y}

  def maybe_align({x, y}, width, height) do
    new_x = rem(x + width, width)
    new_y = rem(y + height, height)

    {new_x, new_y}
  end

  def part1(use_example) do
    input = parse_input(use_example)

    width = if use_example, do: 11, else: 101
    height = if use_example, do: 7, else: 103

    half_width = div(width, 2)
    half_height = div(height, 2)

    input
    |> Enum.reduce(%{}, fn
      {p, v}, locations_count ->
        new_location =
          v
          |> scale_vector(100)
          |> add_vectors(p)
          |> maybe_align(width, height)
          |> maybe_align(width, height)

        locations_count |> Map.update(new_location, 1, &(&1 + 1))
    end)
    |> tap(fn locations_count ->
      IO.puts("locations_count: #{inspect(locations_count)}")
    end)
    |> Enum.reduce({0, 0, 0, 0}, fn
      {{x, y}, _count}, safety_factor when x == half_width or y == half_height ->
        safety_factor

      {{x, y}, count}, {q1, q2, q3, q4} when x < half_width and y < half_height ->
        {q1 + count, q2, q3, q4}

      {{x, y}, count}, {q1, q2, q3, q4} when x > half_width and y < half_height ->
        {q1, q2 + count, q3, q4}

      {{x, y}, count}, {q1, q2, q3, q4} when x < half_width and y > half_height ->
        {q1, q2, q3 + count, q4}

      {{x, y}, count}, {q1, q2, q3, q4} when x > half_width and y > half_height ->
        {q1, q2, q3, q4 + count}
    end)
    |> tap(fn {q1, q2, q3, q4} ->
      IO.puts("q1: #{q1}, q2: #{q2}, q3: #{q3}, q4: #{q4}")
    end)
    |> Tuple.product()
  end

  def gen_straight_line({_x, _y}, {_dx, _dy}, 0), do: []

  def gen_straight_line({x, y}, {dx, dy}, count),
    do: [{x, y} | gen_straight_line({x + dx, y + dy}, {dx, dy}, count - 1)]

  def might_have_christmas_tree?(grid, locations) do
    locations
    |> Enum.any?(fn {x, y} ->
      [
        {-1, -1},
        {1, 1},
        {-1, 1},
        {1, -1}
      ]
      |> Enum.any?(fn {dx, dy} ->
        result =
          gen_straight_line({x, y}, {dx, dy}, 7)
          |> Enum.all?(&(MapSet.member?(locations, &1) && Grid.has(grid, &1)))

        if result do
          IO.puts("Found a path: #{inspect(gen_straight_line({x, y}, {dx, dy}, 7))}")
        end

        result
      end)
    end)
  end

  def part2(use_example) do
    input = parse_input(use_example)

    width = if use_example, do: 11, else: 101
    height = if use_example, do: 7, else: 103

    grid = %Grid{
      data: Tuple.duplicate(" ", width) |> Tuple.duplicate(height),
      width: width,
      height: height
    }

    move =
      fn input, n ->
        input
        |> Enum.reduce(%{}, fn
          {p, v}, locations_count ->
            new_location =
              v
              |> scale_vector(n)
              |> add_vectors(p)
              |> maybe_align(width, height)
              |> maybe_align(width, height)

            locations_count |> Map.update(new_location, [v], &[v | &1])
        end)
      end

    Stream.iterate(
      {input |> move.(0), 0},
      fn {locations, n} ->
        IO.puts(n)

        if might_have_christmas_tree?(grid, locations |> Map.keys() |> MapSet.new()) do
          IO.puts(
            Grid.print_path(
              grid,
              locations |> Map.keys() |> MapSet.new()
            )
          )

          IO.puts(n)
          IO.puts("Christmas tree detected!")
          ch = IO.gets("Press any key to continue...")

          if ch == "q" do
            exit(:normal)
          end
        end

        {
          move.(
            locations |> Enum.flat_map(fn {p, vs} -> vs |> Enum.map(fn v -> {p, v} end) end),
            1
          ),
          n + 1
        }
      end
    )
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      %{"px" => px, "py" => py, "vx" => vx, "vy" => vy} = Regex.named_captures(@line_regex, line)

      {
        {px |> String.to_integer(), py |> String.to_integer()},
        {vx |> String.to_integer(), vy |> String.to_integer()}
      }
    end)
  end
end
