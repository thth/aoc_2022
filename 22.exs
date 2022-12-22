defmodule TwentyTwo do
  def part_one(input) do
    input
    |> parse()
    |> run(:flat)
    |> password()
  end

  # hard coded for my input's net shape / dimensions
  def part_two(input) do
    input
    |> parse()
    |> run(:cube)
    |> password()
  end

  defp parse(text) do
    [grid, directions] = String.split(text, ~r/\R\R/)

    grid =
      grid
      |> String.split(~r/\R/)
      |> Enum.with_index(1)
      |> Enum.map(fn {row, y} ->
        row
        |> String.graphemes()
        |> Enum.with_index(1)
        |> Enum.reject(fn {c, _} -> c == " " end)
        |> Enum.map(fn
          {".", x} -> {{x, y}, true}
          {"#", x} -> {{x, y}, false}
        end)
      end)
      |> List.flatten()
      |> Enum.into(%{})

    directions =
      Regex.scan(~r/\d+|\w/, directions)
      |> List.flatten()
      |> Enum.map(fn str ->
        case Integer.parse(str) do
          :error -> str
          {n, ""} -> n
        end
      end)

    {grid, directions}
  end

  defp password({{x, y}, :east}), do: (y * 1000) + (x * 4) + 0
  defp password({{x, y}, :south}), do: (y * 1000) + (x * 4) + 1
  defp password({{x, y}, :west}), do: (y * 1000) + (x * 4) + 2
  defp password({{x, y}, :north}), do: (y * 1000) + (x * 4) + 3

  defp run({grid, directions}, geometry) do
    {start, _} =
      grid
      |> Enum.filter(fn {{_, y}, c} -> y == 1 and c end)
      |> Enum.min_by(fn {{x, _}, _} -> x end)
    run(directions, grid, {start, :east}, geometry)
  end

  defp run([], _, state, _), do: state
  defp run(["L" | rest], grid, {pos, dir}, geo), do: run(rest, grid, {pos, new_dir(dir, "L")}, geo)
  defp run(["R" | rest], grid, {pos, dir}, geo), do: run(rest, grid, {pos, new_dir(dir, "R")}, geo)
  defp run([0 | rest], grid, state, geo), do: run(rest, grid, state, geo)
  defp run([n | rest], grid, state, geo), do: run([n - 1 | rest], grid, move(state, grid, geo), geo)

  defp new_dir(:north, "L"), do: :west
  defp new_dir(:north, "R"), do: :east
  defp new_dir(:south, "L"), do: :east
  defp new_dir(:south, "R"), do: :west
  defp new_dir(:west, "L"), do: :south
  defp new_dir(:west, "R"), do: :north
  defp new_dir(:east, "L"), do: :north
  defp new_dir(:east, "R"), do: :south

  defp forward({x, y}, :north), do: {x, y - 1}
  defp forward({x, y}, :south), do: {x, y + 1}
  defp forward({x, y}, :west), do: {x - 1, y}
  defp forward({x, y}, :east), do: {x + 1, y}

  defp move({pos, dir}, grid, geo) do
    forward = forward(pos, dir)
    if Map.has_key?(grid, forward) do
      if grid[forward], do: {forward, dir}, else: {pos, dir}
    else
      {next, next_dir} = wrap(pos, dir, grid, geo)
      if grid[next], do: {next, next_dir}, else: {pos, dir}
    end
  end

  defp wrap({x, _}, :north, grid, :flat) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {col, _} -> x == col end)
    |> Enum.max_by(fn {_, row} -> row end)
    |> then(fn next -> {next, :north} end)
  end

  defp wrap({x, _}, :south, grid, :flat) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {col, _} -> x == col end)
    |> Enum.min_by(fn {_, row} -> row end)
    |> then(fn next -> {next, :south} end)
  end

  defp wrap({_, y}, :west, grid, :flat) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {_, row} -> y == row end)
    |> Enum.max_by(fn {col, _} -> col end)
    |> then(fn next -> {next, :west} end)
  end

  defp wrap({_, y}, :east, grid, :flat) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {_, row} -> y == row end)
    |> Enum.min_by(fn {col, _} -> col end)
    |> then(fn next -> {next, :east} end)
  end

  defp wrap({x, _y}, :north, _, :cube) when x in 1..50, do: {{51, 50 + x}, :east}
  defp wrap({x, _y}, :north, _, :cube) when x in 51..100, do: {{1, 150 + x - 50}, :east}
  defp wrap({x, _y}, :north, _, :cube) when x in 101..150, do: {{x - 100, 200}, :north}
  defp wrap({x, _y}, :south, _, :cube) when x in 1..50, do: {{x + 100, 1}, :south}
  defp wrap({x, _y}, :south, _, :cube) when x in 51..100, do: {{50, 150 + x - 50}, :west}
  defp wrap({x, _y}, :south, _, :cube) when x in 101..150, do: {{100, 50 + x - 100}, :west}
  defp wrap({_x, y}, :west, _, :cube) when y in 1..50, do: {{1, 151 - y}, :east}
  defp wrap({_x, y}, :west, _, :cube) when y in 51..100, do: {{y - 50, 101}, :south}
  defp wrap({_x, y}, :west, _, :cube) when y in 101..150, do: {{51, 51 - (y - 100)}, :east}
  defp wrap({_x, y}, :west, _, :cube) when y in 151..200, do: {{50 + y - 150, 1}, :south}
  defp wrap({_x, y}, :east, _, :cube) when y in 1..50, do: {{100, 151 - y}, :west}
  defp wrap({_x, y}, :east, _, :cube) when y in 51..100, do: {{100 + y - 50, 50}, :north}
  defp wrap({_x, y}, :east, _, :cube) when y in 101..150, do: {{150, 51 - (y - 100)}, :west}
  defp wrap({_x, y}, :east, _, :cube) when y in 151..200, do: {{50 + y - 150, 150}, :north}
end

input = File.read!("input/22.txt")

input |> TwentyTwo.part_one() |> IO.inspect(label: "part 1")
input |> TwentyTwo.part_two() |> IO.inspect(label: "part 2")
