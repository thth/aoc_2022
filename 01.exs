defmodule One do
  def part_one(input) do
    input
    |> parse()
    |> Enum.max_by(&Enum.sum/1)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(&>/2)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> Enum.map(fn block ->
      block
      |> String.split(~r/\R/)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end

input = File.read!("input/01.txt")

input |> One.part_one() |> IO.inspect(label: "part 1")
input |> One.part_two() |> IO.inspect(label: "part 2")
