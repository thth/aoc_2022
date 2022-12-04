defmodule Four do
  def part_one(input) do
    input
    |> parse()
    |> Enum.count(fn {a..b, c..d} ->
      a >= c and b <= d or
      c >= a and d <= b
    end)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.count(fn {a..b, c..d} ->
      a in c..d or
      b in c..d or
      c in a..b or
      d in a..b
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split([",", "-"])
      |> Enum.map(&String.to_integer/1)
      |> then(fn [a, b, c, d] -> {a..b, c..d} end)
    end)
  end
end

input = File.read!("input/04.txt")

input |> Four.part_one() |> IO.inspect(label: "part 1")
input |> Four.part_two() |> IO.inspect(label: "part 2")
