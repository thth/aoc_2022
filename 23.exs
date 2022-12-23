defmodule TwentyThree do
  def part_one(input) do
    map =
      input
      |> parse()
      |> simulate(10)
    {{x_min, _}, {x_max, _}} = Enum.min_max_by(map, &elem(&1, 0))
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(map, &elem(&1, 1))

    (x_max - x_min + 1) * (y_max - y_min + 1) - MapSet.size(map)
  end

  def part_two(input) do
    Stream.iterate({parse(input), 0}, fn {elves, step} -> {simulate_step(elves, step), step + 1} end)
    |> Stream.chunk_every(2, 1)
    |> Enum.find(fn [{old, _}, {new, _}] -> old == new end)
    |> Enum.at(1)
    |> elem(1)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reject(fn {c, _} -> c == "." end)
      |> Enum.map(fn {"#", x} -> {x, y} end)
    end)
    |> List.flatten()
    |> MapSet.new()
  end

  defp simulate(elves, steps), do: simulate(elves, 0, steps)
  defp simulate(elves, n, n), do: elves
  defp simulate(elves, n, steps) do
    new_elves = simulate_step(elves, n)
    simulate(new_elves, n + 1, steps)
  end

  defp simulate_step(elves, n) do
    valid_proposals =
      Enum.reduce(elves, %{}, fn elf, acc ->
        cond do
          surroundings_clear?(elf, elves) -> acc
          proposal = propose(elf, elves, n) ->
            Map.update(acc, proposal, [elf], fn rest -> [elf | rest] end)
          true -> acc
        end
      end)
      |> Enum.filter(fn {_, proposers} -> length(proposers) == 1 end)

    without_old =
      valid_proposals
      |> Enum.map(&elem(&1, 1))
      |> List.flatten()
      |> MapSet.new()
      |> then(fn old_pos -> MapSet.difference(elves, old_pos) end)

    valid_proposals
    |> Enum.map(&elem(&1, 0))
    |> MapSet.new()
    |> MapSet.union(without_old)
  end

  defp propose({x, y}, elves, n) do
    [
      {[{-1, -1}, {0, -1}, {1, -1}], {0, -1}},
      {[{-1, 1}, {0, 1}, {1, 1}], {0, 1}},
      {[{-1, -1}, {-1, 0}, {-1, 1}], {-1, 0}},
      {[{1, -1}, {1, 0}, {1, 1}], {1, 0}}
    ]
    |> Stream.cycle()
    |> Enum.slice(rem(n, 4), 4)
    |> Enum.find(fn {clears, _} ->
      not Enum.any?(clears, fn {dx, dy} -> MapSet.member?(elves, {x + dx, y + dy}) end)
    end)
    |> then(fn
      nil -> nil
      {_, {dx, dy}} -> {x + dx, y + dy}
    end)
  end

  defp surroundings_clear?({x, y}, elves) do
    [
      {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
      {x - 1, y}, {x + 1, y},
      {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
    ]
    |> Enum.any?(&MapSet.member?(elves, &1))
    |> Kernel.not()
  end
end

input = File.read!("input/23.txt")

input |> TwentyThree.part_one() |> IO.inspect(label: "part 1")
input |> TwentyThree.part_two() |> IO.inspect(label: "part 2")
