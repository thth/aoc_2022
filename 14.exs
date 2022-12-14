defmodule Fourteen do
  def part_one(input) do
    input
    |> parse()
    |> simulate()
  end

  def part_two(input) do
    input
    |> parse()
    |> simulate_until_full()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split([" -> ", ","])
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(4, 2, :discard)
      |> Enum.reduce(MapSet.new(), fn
        [x, y1, x, y2], acc ->
          (for y <- y1..y2, do: {x, y})
          |> MapSet.new()
          |> MapSet.union(acc)
        [x1, y, x2, y], acc ->
          (for x <- x1..x2, do: {x, y})
          |> MapSet.new()
          |> MapSet.union(acc)
      end)
    end)
    |> Enum.reduce(&MapSet.union/2)
  end

  defp simulate(rock), do: simulate(rock, 0)
  defp simulate(rock, count, {x, y} \\ {500, 0}) do
    cond do
      abyss_below?(rock, {x, y}) -> count
      empty_under?(rock, {x, y}) -> simulate(rock, count, {x, y + 1})
      empty_left?(rock, {x, y}) -> simulate(rock, count, {x - 1, y + 1})
      empty_right?(rock, {x, y}) -> simulate(rock, count, {x + 1, y + 1})
      true -> simulate(MapSet.put(rock, {x, y}), count + 1)
    end
  end

  defp full?(rock), do: MapSet.member?(rock, {500, 0})
  defp abyss_below?(rock, {x, y}), do: not Enum.any?(rock, fn {rx, ry} -> rx == x and ry > y end)
  defp empty_under?(rock, {x, y}), do: not MapSet.member?(rock, {x, y + 1})
  defp empty_left?(rock, {x, y}), do: not MapSet.member?(rock, {x - 1, y + 1})
  defp empty_right?(rock, {x, y}), do: not MapSet.member?(rock, {x + 1, y + 1})

  defp simulate_until_full(rock) do
    {_, rb} = Enum.max_by(rock, fn {_, ry} -> ry end)
    simulate_until_full(rock, rb + 1, 0)
  end
  defp simulate_until_full(rock, sb, count, {x, y} \\ {500, 0}) do
    cond do
      full?(rock) -> count
      y == sb -> simulate_until_full(MapSet.put(rock, {x, y}), sb, count + 1)
      empty_under?(rock, {x, y}) -> simulate_until_full(rock, sb, count, {x, y + 1})
      empty_left?(rock, {x, y}) -> simulate_until_full(rock, sb, count, {x - 1, y + 1})
      empty_right?(rock, {x, y}) -> simulate_until_full(rock, sb, count, {x + 1, y + 1})
      true -> simulate_until_full(MapSet.put(rock, {x, y}), sb, count + 1)
    end
  end
end

input = File.read!("input/14.txt")

input |> Fourteen.part_one() |> IO.inspect(label: "part 1")
input |> Fourteen.part_two() |> IO.inspect(label: "part 2")
