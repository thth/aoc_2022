defmodule Seventeen do
  @n 1_000_000_000_000
  def part_one(input) do
    input
    |> parse()
    |> Stream.cycle()
    |> simulate_until(2022)
    |> elem(0)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  def part_two(input) do
    buffer = 250
    check = 4000
    {_, dys} =
      input
      |> parse()
      |> Stream.cycle()
      |> simulate_until(check)
    cycle_n =
      dys
      |> Enum.slice(buffer..-1//1)
      |> then(fn list ->
        div(check - buffer, 2)..1
        |> Enum.find(fn n ->
          Enum.slice(list, 0..(n-1)) == Enum.slice(list, n..(n*2-1))
        end)
      end)
    cycle = Enum.slice(dys, buffer+1..buffer+cycle_n)
    cycle_h = Enum.sum(cycle)
    base_h = dys |> Enum.slice(0..(buffer - 1)) |> Enum.sum()
    rest = cycle |> Enum.slice(0..rem(@n - buffer - 1, length(cycle))) |> Enum.sum()
    base_h + (cycle_h * div(@n - buffer, length(cycle))) + rest
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.graphemes()
  end

  defp simulate_until(stream, until), do: simulate_until(stream, 0, MapSet.new(), [], 0, until)
  defp simulate_until(_, _, map, dys, n, n), do: {map, Enum.reverse(dys)}
  defp simulate_until(stream, stream_i, map, dys, n, until) do
    {placed_rock, new_i} =
      {new_rock(map, n), stream_i}
      |> Stream.iterate(fn {rock, i} ->
        {blow_and_fall(rock, map, Enum.at(stream, i)), i + 1}
      end)
      |> Enum.find(fn {rock, _} -> rock_stopped?(rock, map) end)
      |> then(fn {rock, i} -> {raise_rock(rock), i} end)
    new_map = placed_rock |> MapSet.new() |> MapSet.union(map)
    dy = max_height(new_map) - max_height(map)
    simulate_until(stream, new_i, new_map, [dy | dys], n + 1, until)
  end

  defp new_rock(map, n) do
    top = Enum.max_by(map, fn {_, cy} -> cy end, fn -> {0, 0} end) |> elem(1) |> Kernel.+(4)
    [
      [{2, 0}, {3, 0}, {4, 0}, {5, 0}],
      [{3, 0}, {2, 1}, {3, 1}, {4, 1}, {3, 2}],
      [{2, 0}, {3, 0}, {4, 0}, {4, 1}, {4, 2}],
      [{2, 0}, {2, 1}, {2, 2}, {2, 3}],
      [{2, 0}, {3, 0}, {2, 1}, {3, 1}]
    ]
    |> Enum.at(rem(n, 5))
    |> Enum.map(fn {x, y} -> {x, y + top} end)
  end

  defp rock_stopped?(rock, map), do: Enum.any?(rock, fn {x, y} -> y == 0 or MapSet.member?(map, {x, y}) end)

  defp blow_and_fall(rock, map, dir) do
    rock
    |> blow(map, dir)
    |> Enum.map(fn {x, y} -> {x, y - 1} end)
  end

  defp blow(rock, map, "<") do
    blown = Enum.map(rock, fn {x, y} -> {x - 1, y} end)
    if Enum.any?(blown, fn {x, y} -> x < 0 or MapSet.member?(map, {x, y}) end) do
      rock
    else
      blown
    end
  end

  defp blow(rock, map, ">") do
    blown = Enum.map(rock, fn {x, y} -> {x + 1, y} end)
    if Enum.any?(blown, fn {x, y} -> x > 6 or MapSet.member?(map, {x, y}) end) do
      rock
    else
      blown
    end
  end

  defp raise_rock(rock), do: Enum.map(rock, fn {x, y} -> {x, y + 1} end)

  defp max_height(map), do: map |> Enum.max_by(&elem(&1, 1), fn -> {0, 0} end) |> elem(1)
end

input = File.read!("input/17.txt")

input |> Seventeen.part_one() |> IO.inspect(label: "part 1")
input |> Seventeen.part_two() |> IO.inspect(label: "part 2")
