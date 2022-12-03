defmodule Three do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn line ->
      line
      |> Enum.chunk_every(line |> length() |> div(2))
      |> Enum.map(&MapSet.new/1)
      |> Enum.reduce(&MapSet.intersection/2)
      |> Enum.at(0)
      |> priority()
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&MapSet.new/1)
    |> Enum.chunk_every(3)
    |> Enum.map(fn chunk ->
      chunk
      |> Enum.reduce(&MapSet.intersection/2)
      |> Enum.at(0)
      |> priority()
    end)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.to_charlist/1)
  end

  def priority(n) do
    char = List.to_string([n])
    if char == String.upcase(char) do
      n - ?A + 1 + 26
    else
      n - ?a + 1
    end
  end
end

input = File.read!("input/03.txt")

input |> Three.part_one() |> IO.inspect(label: "part 1")
input |> Three.part_two() |> IO.inspect(label: "part 2")
