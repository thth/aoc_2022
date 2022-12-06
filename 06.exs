defmodule Six do
  def part_one(input) do
    input
    |> parse()
    |> Enum.chunk_every(4, 1)
    |> Enum.find_index(&(&1 == Enum.uniq(&1)))
    |> Kernel.+(4)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.chunk_every(14, 1)
    |> Enum.find_index(&(&1 == Enum.uniq(&1)))
    |> Kernel.+(14)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.graphemes()
  end
end

input = File.read!("input/06.txt")

input |> Six.part_one() |> IO.inspect(label: "part 1")
input |> Six.part_two() |> IO.inspect(label: "part 2")
