defmodule Eight do
  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&rotate/1)
    |> Enum.take(4)
    |> Enum.map(&visible/1)
    |> Enum.reduce(&MapSet.union/2)
    |> MapSet.size()
  end

  def part_two(input) do
    trees = parse(input)
    tree_map = trees |> List.flatten() |> Enum.into(%{})
    x_max = tree_map |> Map.keys() |> Enum.max_by(&elem(&1, 0)) |> elem(0)
    y_max = tree_map |> Map.keys() |> Enum.max_by(&elem(&1, 1)) |> elem(1)

    tree_map
    |> Enum.map(&scenic_score(&1, tree_map, x_max, y_max))
    |> Enum.max()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      Enum.map(row, fn {h, x} ->
        {{x, y}, String.to_integer(h)}
      end)
    end)
  end

  defp visible(trees) do
    Enum.reduce(trees, MapSet.new(), fn row, acc ->
      Enum.reduce(row, {acc, 0}, fn
        {pos, h}, {a, max_h} when h > max_h -> {MapSet.put(a, pos), h}
        _, a -> a
      end)
      |> elem(0)
    end)
  end

  defp rotate(trees), do: trees |> Enum.reverse() |> Enum.zip() |> Enum.map(&Tuple.to_list/1)

  defp scenic_score({{0, _}, _}, _, _, _), do: 0
  defp scenic_score({{_, 0}, _}, _, _, _), do: 0
  defp scenic_score({{x_max, _}, _}, _, x_max, _), do: 0
  defp scenic_score({{_, y_max}, _}, _, _, y_max), do: 0
  defp scenic_score({{x_pos, y_pos}, h}, tree_map, x_max, y_max) do
    [
      (for y <- (y_pos - 1)..0, do: {x_pos, y}),
      (for y <- (y_pos + 1)..y_max, do: {x_pos, y}),
      (for x <- (x_pos - 1)..0, do: {x, y_pos}),
      (for x <- (x_pos + 1)..x_max, do: {x, y_pos}),
    ]
    |> Enum.map(&viewing_distance(&1, h, tree_map))
    |> Enum.product()
  end

  defp viewing_distance(coords, h, tree_map) do
    coords
    |> Enum.map(&(tree_map[&1]))
    |> Enum.reduce_while(0, fn
      tree_h, count when tree_h < h -> {:cont, count + 1}
      _, count -> {:halt, count + 1}
    end)
  end
end

input = File.read!("input/08.txt")

input |> Eight.part_one() |> IO.inspect(label: "part 1")
input |> Eight.part_two() |> IO.inspect(label: "part 2")
