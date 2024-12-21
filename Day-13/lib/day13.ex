defmodule Day13 do
  @btn_regex ~r/^Button .: X\+(\d+), Y\+(\d+)$/
  @prize_regex ~r/^Prize: X\=(\d+), Y\=(\d+)$/

  # System of 2 equations:
  # [a1 a2][x] = [c1]
  # [b1 b2][y] = [c2]
  def solve(
        a: [x: a1, y: b1],
        b: [x: a2, y: b2],
        prize: [x: c1, y: c2]
      ) do
    delta = Decimal.mult(a1, b2) |> Decimal.sub(Decimal.mult(a2, b1))

    x = Decimal.mult(c1, b2) |> Decimal.sub(Decimal.mult(c2, a2)) |> Decimal.div(delta)
    y = Decimal.mult(c2, a1) |> Decimal.sub(Decimal.mult(c1, b1)) |> Decimal.div(delta)

    {x, y}
  end

  def part1(use_example) do
    input = parse_input(use_example)

    input
    |> Enum.map(fn
      param ->
        {a, b} = solve(param)

        if a |> Decimal.integer?() and
             b |> Decimal.integer?() do
          Decimal.to_integer(a) * 3 + Decimal.to_integer(b)
        else
          0
        end
    end)
    |> Enum.sum()
  end

  def part2(use_example) do
    input = parse_input(use_example)

    input
    |> Enum.map(fn
      [a: [x: a1, y: b1], b: [x: a2, y: b2], prize: [x: c1, y: c2]] ->
        {a, b} =
          solve(
            a: [x: a1, y: b1],
            b: [x: a2, y: b2],
            prize: [
              x: c1 |> Decimal.add(10_000_000_000_000),
              y: c2 |> Decimal.add(10_000_000_000_000)
            ]
          )

        if a |> Decimal.integer?() and
             b |> Decimal.integer?() do
          Decimal.to_integer(a) * 3 + Decimal.to_integer(b)
        else
          0
        end
    end)
    |> Enum.sum()
  end

  def parse_input(use_example) do
    filename = if use_example, do: "example-input.txt", else: "input.txt"

    filename
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn line ->
      [a, b, prize] = line |> String.split("\n", trim: true, parts: 3)

      [parsed_a] = @btn_regex |> Regex.scan(a)
      [parsed_b] = @btn_regex |> Regex.scan(b)
      [parsed_prize] = @prize_regex |> Regex.scan(prize)

      [
        a: [
          x: parsed_a |> Enum.at(1) |> Decimal.parse() |> elem(0),
          y: parsed_a |> Enum.at(2) |> Decimal.parse() |> elem(0)
        ],
        b: [
          x: parsed_b |> Enum.at(1) |> Decimal.parse() |> elem(0),
          y: parsed_b |> Enum.at(2) |> Decimal.parse() |> elem(0)
        ],
        prize: [
          x: parsed_prize |> Enum.at(1) |> Decimal.parse() |> elem(0),
          y: parsed_prize |> Enum.at(2) |> Decimal.parse() |> elem(0)
        ]
      ]
    end)
  end
end
