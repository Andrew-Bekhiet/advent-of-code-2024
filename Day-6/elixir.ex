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
end

defmodule Day6 do
  defp rotate_heading(:up), do: :right
  defp rotate_heading(:right), do: :down
  defp rotate_heading(:down), do: :left
  defp rotate_heading(:left), do: :up

  defp get_new_pos({x, y}, :up), do: {x, y - 1}
  defp get_new_pos({x, y}, :down), do: {x, y + 1}
  defp get_new_pos({x, y}, :left), do: {x - 1, y}
  defp get_new_pos({x, y}, :right), do: {x + 1, y}

  defp trace(%Grid{} = grid, {x, y} = current_pos, heading, visited \\ MapSet.new()) do
    new_pos = get_new_pos(current_pos, heading)
    new_pos_value = grid |> Grid.at(new_pos)

    updated_visited = visited |> MapSet.put(current_pos)

    case new_pos_value do
      nil ->
        IO.puts("Finished at #{inspect(current_pos)}")

        updated_visited

      "#" ->
        IO.puts("Found a wall at #{inspect(current_pos)}")

        updated_visited
        |> MapSet.union(grid |> trace(current_pos, rotate_heading(heading)))

      _ ->
        IO.puts("Tracing from #{inspect(current_pos)}")

        updated_visited
        |> MapSet.union(grid |> trace(new_pos, heading))
    end
  end

  defp find_initial_pos_and_heading(%Grid{data: data}) do
    data
    |> Enum.with_index()
    |> Enum.find_value(fn {line, y} ->
      line
      |> Enum.with_index()
      |> Enum.find_value(fn {char, x} ->
        if char in ["^", "v", "<", ">"] do
          heading =
            case char do
              "^" -> :up
              "v" -> :down
              "<" -> :left
              ">" -> :right
            end

          {{x, y}, heading}
        else
          false
        end
      end)
    end)
  end

  def part1(use_example) do
    grid = parse_input(use_example)

    IO.puts(inspect(grid, pretty: true))

    {initial_pos, heading} = find_initial_pos_and_heading(grid)

    grid
    |> trace(initial_pos, heading)
    |> MapSet.size()
  end

  def part2(use_example) do
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    Grid.parse(filename |> File.read!())
  end
end
