defmodule Twelve do
  def part_one(input) do
    {map, start, dest} = parse(input)

    path(map, start, dest)
  end

  def part_two(input) do
    {map, _, dest} = parse(input)

    reverse_path(map, dest)
  end

  defp parse(text) do
    map =
      text
      |> String.trim()
      |> String.split(~r/\R/)
      |> Enum.map(fn line ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
      end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y}, acc ->
        Enum.reduce(row, acc, fn {c, x}, a ->
          Map.put(a, {x, y}, c)
        end)
      end)

    {start, _} = Enum.find(map, fn {_, h} -> h == ?S end)
    {dest, _} = Enum.find(map, fn {_, h} -> h == ?E end)
    map = map |> Map.put(start, ?a) |> Map.put(dest, ?z)

    {map, start, dest}
  end

  defp path(map, start, dest), do: path(map, [start], [], MapSet.new(), 0, dest)
  defp path(map, [], next, seen, steps, dest), do: path(map, next, [], seen, steps + 1, dest)
  defp path(map, [pos | rest], next, seen, steps, dest) do
    adj = adjacent(pos, map, seen)
    if dest in adj do
      steps + 1
    else
      path(map, rest, adj ++ next, adj |> MapSet.new() |> MapSet.union(seen), steps, dest)
    end
  end

  defp adjacent({x, y}, map, seen) do
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.filter(fn pos -> Map.has_key?(map, pos) end)
    |> Enum.reject(&MapSet.member?(seen, &1))
    |> Enum.filter(fn pos -> map[{x, y}] + 1 >= map[pos] end)
  end

  defp reverse_path(map, start), do: reverse_path(map, [start], [], MapSet.new(), 0)
  defp reverse_path(map, [], next, seen, steps), do: reverse_path(map, next, [], seen, steps + 1)
  defp reverse_path(map, [pos | rest], next, seen, steps) do
    adj = reverse(pos, map, seen)
    if Enum.find(adj, fn p -> map[p] == ?a end) do
      steps + 1
    else
      reverse_path(map, rest, adj ++ next, adj |> MapSet.new() |> MapSet.union(seen), steps)
    end
  end

  defp reverse({x, y}, map, seen) do
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.filter(fn pos -> Map.has_key?(map, pos) end)
    |> Enum.reject(&MapSet.member?(seen, &1))
    |> Enum.filter(fn pos -> map[{x, y}] - 1 <= map[pos] end)
  end
end

input = File.read!("input/12.txt")

input |> Twelve.part_one() |> IO.inspect(label: "part 1")
input |> Twelve.part_two() |> IO.inspect(label: "part 2")
