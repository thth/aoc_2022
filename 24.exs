defmodule TwentyFour do
  def part_one(input) do
    {map, blizzards} = parse(input)
    {{x_min, _}, {x_max, _}} = Enum.min_max_by(map, &elem(&1, 0))
    {start = {_, y_min}, finish = {_, y_max}} = Enum.min_max_by(map, &elem(&1, 1))

    Stream.iterate({{x_min..x_max, (y_min + 1)..(y_max - 1)}, blizzards}, &step/1)
    |> Stream.map(fn {_, blizzards} -> blizzards |> Enum.map(&elem(&1, 0)) |> MapSet.new() end)
    |> Stream.with_index()
    |> Enum.reduce_while(MapSet.new([start]), fn {blizzard_pos, n}, possible ->
      if MapSet.member?(possible, finish) do
        {:halt, n - 1}
      else
        possible
        |> Enum.map(fn pos ->
          nexts(pos, x_min..x_max, (y_min + 1)..(y_max - 1), [start, finish], blizzard_pos)
        end)
        |> List.flatten()
        |> MapSet.new()
        |> then(&({:cont, &1}))
      end
    end)
  end

  def part_two(input) do
    {map, blizzards} = parse(input)
    {{x_min, _}, {x_max, _}} = Enum.min_max_by(map, &elem(&1, 0))
    {start = {_, y_min}, finish = {_, y_max}} = Enum.min_max_by(map, &elem(&1, 1))

    Stream.iterate({{x_min..x_max, (y_min + 1)..(y_max - 1)}, blizzards}, &step/1)
    |> Stream.map(fn {_, blizzards} -> blizzards |> Enum.map(&elem(&1, 0)) |> MapSet.new() end)
    |> Stream.with_index()
    |> Enum.reduce_while(MapSet.new([{start, 0}]), fn {blizzard_pos, n}, possible ->
      if MapSet.member?(possible, {finish, 2}) do
        {:halt, n - 1}
      else
        possible
        |> Enum.map(fn {pos, state} ->
          nexts(pos, x_min..x_max, (y_min + 1)..(y_max - 1), [start, finish], blizzard_pos)
          |> Enum.map(fn
            ^finish when state == 0 -> {finish, 1}
            ^start when state == 1 -> {start, 2}
            next_pos -> {next_pos, state}
          end)
        end)
        |> List.flatten()
        |> MapSet.new()
        |> then(&({:cont, &1}))
      end
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce({MapSet.new(), []}, fn {row, y}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reject(fn {c, _} -> c == "#" end)
      |> Enum.reduce(acc, fn
        {".", x}, {map_acc, blizzards_acc} -> {MapSet.put(map_acc, {x, y}), blizzards_acc}
        {b, x}, {map_acc, blizzards_acc} -> {MapSet.put(map_acc, {x, y}), [{{x, y}, b} | blizzards_acc]}
      end)
    end)
  end

  defp step({ranges, blizzards}), do: step(ranges, blizzards, [])
  defp step(ranges, [], next), do: {ranges, next}
  defp step(ranges, [blizzard | rest], next), do: step(ranges, rest, [advance(blizzard, ranges) | next])

  defp advance({{x, y}, "^"}, {_, y_min..y_max}), do: if y == y_min, do: {{x, y_max}, "^"}, else: {{x, y - 1}, "^"}
  defp advance({{x, y}, "v"}, {_, y_min..y_max}), do: if y == y_max, do: {{x, y_min}, "v"}, else: {{x, y + 1}, "v"}
  defp advance({{x, y}, "<"}, {x_min..x_max, _}), do: if x == x_min, do: {{x_max, y}, "<"}, else: {{x - 1, y}, "<"}
  defp advance({{x, y}, ">"}, {x_min..x_max, _}), do: if x == x_max, do: {{x_min, y}, ">"}, else: {{x + 1, y}, ">"}

  defp nexts({x, y}, x_min..x_max, y_min..y_max, exceptions, blizzard_pos) do
    [{x, y}, {x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.reject(fn {cx, cy} = pos ->
      if pos in exceptions do
        false
      else
        cx < x_min or cx > x_max or cy < y_min or cy > y_max or MapSet.member?(blizzard_pos, pos)
      end
    end)
  end
end

input = File.read!("input/24.txt")

input |> TwentyFour.part_one() |> IO.inspect(label: "part 1")
input |> TwentyFour.part_two() |> IO.inspect(label: "part 2")
