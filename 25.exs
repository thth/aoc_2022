defmodule TwentyFive do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&parse_snafu/1)
    |> Enum.sum()
    |> to_snafu()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.graphemes/1)
  end

  defp parse_snafu(snafu), do: parse_snafu(Enum.reverse(snafu), 0, 0)
  defp parse_snafu([], _, result), do: result
  defp parse_snafu([c | rest], power, result), do: parse_snafu(rest, power + 1, result + (int(c) * (5 ** power)))

  defp int("2"), do: 2
  defp int("1"), do: 1
  defp int("0"), do: 0
  defp int("-"), do: -1
  defp int("="), do: -2
  defp int(n), do: n

  defp to_snafu(n) do
    start = round(:math.log(n) / :math.log(5))

    Enum.reduce(start..0, List.duplicate(0, start + 1), fn p, acc ->
      Enum.min_by(-2..2, fn x -> abs(n - (parse_snafu(acc) + (x * (5 ** p)))) end)
      |> then(&List.replace_at(acc, start - p, &1))
    end)
    |> Enum.map(fn
      2 -> "2"
      1 -> "1"
      0 -> "0"
      -1 -> "-"
      -2 -> "="
    end)
    |> Enum.join("")
  end
end

input = File.read!("input/25.txt")

input |> TwentyFive.part_one() |> IO.inspect(label: "part 1")
