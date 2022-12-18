defmodule Eighteen do
  def part_one(input) do
    input
    |> parse()
    |> count_sides()
  end

  def part_two(input) do
    cubes = parse(input)
    interior = get_interior(cubes)

    count_sides(cubes, MapSet.new(interior ++ cubes), 0)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp count_sides(cubes), do: count_sides(cubes, MapSet.new(cubes), 0)
  defp count_sides([], _, sides), do: sides
  defp count_sides([cube | rest], cubes, sides) do
    to_add =
      adjacents(cube)
      |> Enum.count(&MapSet.member?(cubes, &1))
      |> then(fn n -> 6 - n end)
    count_sides(rest, cubes, sides + to_add)
  end

  defp adjacents({x, y, z}), do: [{x+1, y, z}, {x-1, y, z}, {x, y+1, z}, {x, y-1, z}, {x, y, z+1}, {x, y, z-1}]

  defp get_interior(cubes) do
    {{x_min, _, _}, {x_max, _, _}} = Enum.min_max_by(cubes, &elem(&1, 0))
    {{_, y_min, _}, {_, y_max, _}} = Enum.min_max_by(cubes, &elem(&1, 1))
    {{_, _, z_min}, {_, _, z_max}} = Enum.min_max_by(cubes, &elem(&1, 2))

    outside =
      ((for x <- x_min..x_max, y <- y_min..y_max, z <- [z_min, z_max], do: {x, y, z})
      ++ (for x <- x_min..x_max, y <- [y_min, y_max], z <- z_min..z_max, do: {x, y, z})
      ++ (for x <- [x_min, x_max], y <- y_min..y_max, z <- z_min..z_max, do: {x, y, z}))
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(cubes))

    air =
      (for x <- x_min..x_max, y <- y_min..y_max, z <- z_min..z_max, do: {x, y, z})
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(cubes))
      |> MapSet.difference(outside)
      |> Enum.to_list()

    get_interior(air, [], air, outside)
  end

  defp get_interior([], past, last_air, outside) do
    reverse_past = Enum.reverse(past)
    if reverse_past == last_air do
      last_air
    else
      get_interior(reverse_past, [], reverse_past, outside)
    end
  end
  defp get_interior([air | rest], past, last_air, outside) do
    touching_outside? =
      adjacents(air)
      |> Enum.any?(&MapSet.member?(outside, &1))
    if touching_outside? do
      get_interior(rest, past, last_air, MapSet.put(outside, air))
    else
      get_interior(rest, [air | past], last_air, outside)
    end
  end
end

input = File.read!("input/18.txt")

input |> Eighteen.part_one() |> IO.inspect(label: "part 1")
input |> Eighteen.part_two() |> IO.inspect(label: "part 2")
