defmodule Two do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&score_one/1)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&score_two/1)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> List.to_tuple()
    end)
  end

  defp score_one(line) do
    case line do
      {"A", "X"} -> 1 + 3
      {"B", "X"} -> 1 + 0
      {"C", "X"} -> 1 + 6
      {"A", "Y"} -> 2 + 6
      {"B", "Y"} -> 2 + 3
      {"C", "Y"} -> 2 + 0
      {"A", "Z"} -> 3 + 0
      {"B", "Z"} -> 3 + 6
      {"C", "Z"} -> 3 + 3
    end
  end

  defp score_two(line) do
    case line do
      {"A", "X"} -> 0 + 3
      {"B", "X"} -> 0 + 1
      {"C", "X"} -> 0 + 2
      {"A", "Y"} -> 3 + 1
      {"B", "Y"} -> 3 + 2
      {"C", "Y"} -> 3 + 3
      {"A", "Z"} -> 6 + 2
      {"B", "Z"} -> 6 + 3
      {"C", "Z"} -> 6 + 1
    end
  end
end

input = File.read!("input/02.txt")

input |> Two.part_one() |> IO.inspect(label: "part 1")
input |> Two.part_two() |> IO.inspect(label: "part 2")
