defmodule Nine do
  def part_one(input) do
    input
    |> parse()
    |> simulate({0, 0}, [{0, 0}])
  end

  def part_two(input) do
    input
    |> parse()
    |> simulate({0, 0}, List.duplicate({0, 0}, 9))
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [d, n] -> {d, String.to_integer(n)} end)
  end

  defp simulate(steps, head, tails), do: simulate(steps, head, tails, MapSet.new([List.last(tails)]))
  defp simulate([], _, _, been), do: MapSet.size(been)
  defp simulate([{_, 0} | rest], head, tails, been), do: simulate(rest, head, tails, been)
  defp simulate([{dir, n} | rest], head, tails, been) do
    next_head = move_head(head, dir)
    next_tails = move_tails(next_head, tails)
    new_been = MapSet.put(been, List.last(next_tails))
    simulate([{dir, n - 1} | rest], next_head, next_tails, new_been)
  end

  defp move_head({x, y}, "U"), do: {x, y - 1}
  defp move_head({x, y}, "D"), do: {x, y + 1}
  defp move_head({x, y}, "L"), do: {x - 1, y}
  defp move_head({x, y}, "R"), do: {x + 1, y}

  defp move_tails(head, tails) do
    Enum.reduce(tails, {head, []}, fn tail, {ahead, new_tails} ->
      new_tail = move_tail(ahead, tail)
      {new_tail, new_tails ++ [new_tail]}
    end)
    |> elem(1)
  end

  defp move_tail({hx, hy}, {tx, ty}) when abs(tx - hx) <= 1 and abs(ty - hy) <= 1, do: {tx, ty}
  defp move_tail({tx, hy}, {tx, ty}) when hy > ty, do: {tx, ty + 1}
  defp move_tail({tx, hy}, {tx, ty}) when hy < ty, do: {tx, ty - 1}
  defp move_tail({hx, ty}, {tx, ty}) when hx > tx, do: {tx + 1, ty}
  defp move_tail({hx, ty}, {tx, ty}) when hx < tx, do: {tx - 1, ty}
  defp move_tail({hx, hy}, {tx, ty}) when hx > tx and hy > ty, do: {tx + 1, ty + 1}
  defp move_tail({hx, hy}, {tx, ty}) when hx < tx and hy > ty, do: {tx - 1, ty + 1}
  defp move_tail({hx, hy}, {tx, ty}) when hx > tx and hy < ty, do: {tx + 1, ty - 1}
  defp move_tail({hx, hy}, {tx, ty}) when hx < tx and hy < ty, do: {tx - 1, ty - 1}
end

input = File.read!("input/09.txt")

input |> Nine.part_one() |> IO.inspect(label: "part 1")
input |> Nine.part_two() |> IO.inspect(label: "part 2")
