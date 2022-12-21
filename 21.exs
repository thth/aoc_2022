defmodule TwentyOne do
  def part_one(input) do
    input
    |> parse()
    |> eval("root")
  end

  def part_two(input) do
    input
    |> parse()
    |> Map.delete("humn")
    |> Map.update!("root", fn {_, a, b} -> {"=", a, b} end)
    |> build("root")
    |> algebra()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/\w+|\d+|[\+\-\*\/]/, line)
      |> List.flatten()
      |> then(fn
        [monkey, n] -> {monkey, String.to_integer(n)}
        [monkey, a, op, b] -> {monkey, {op, a, b}}
      end)
    end)
    |> Enum.into(%{})
  end

  defp eval(map, monkey) do
    case map[monkey] do
      {"+", a, b} -> eval(map, a) + eval(map, b)
      {"-", a, b} -> eval(map, a) + eval(map, b)
      {"*", a, b} -> eval(map, a) * eval(map, b)
      {"/", a, b} -> div(eval(map, a), eval(map, b))
      n -> n
    end
  end

  defp build(_, "humn"), do: [true, "humn"]
  defp build(map, monkey) do
    case map[monkey] do
      {op, a, b} ->
        built_a = build(map, a)
        built_b = build(map, b)
        has_humn? = hd(built_a) or hd(built_b)
        [has_humn?, op, built_a, built_b]
      n -> [false, n]
    end
  end

  defp algebra([false, n]), do: n
  defp algebra([false, "+", a, b]), do: algebra(a) + algebra(b)
  defp algebra([false, "-", a, b]), do: algebra(a) - algebra(b)
  defp algebra([false, "*", a, b]), do: algebra(a) * algebra(b)
  defp algebra([false, "/", a, b]), do: div(algebra(a), algebra(b))
  defp algebra([true, "=", a, b]) when hd(a), do: algebra(a, algebra(b))
  defp algebra([true, "=", a, b]) when hd(b), do: algebra(b, algebra(a))
  defp algebra([true, "humn"], n), do: n
  defp algebra([true, "+", a, b], n) when hd(a), do: algebra(a, n - algebra(b))
  defp algebra([true, "+", a, b], n) when hd(b), do: algebra(b, n - algebra(a))
  defp algebra([true, "-", a, b], n) when hd(a), do: algebra(a, n + algebra(b))
  defp algebra([true, "-", a, b], n) when hd(b), do: algebra(b, algebra(a) - n)
  defp algebra([true, "*", a, b], n) when hd(a), do: algebra(a, div(n, algebra(b)))
  defp algebra([true, "*", a, b], n) when hd(b), do: algebra(b, div(n, algebra(a)))
  defp algebra([true, "/", a, b], n) when hd(a), do: algebra(a, n * algebra(b))
  defp algebra([true, "/", a, b], n) when hd(b), do: algebra(b, div(algebra(a), n))
end

input = File.read!("input/21.txt")

input |> TwentyOne.part_one() |> IO.inspect(label: "part 1")
input |> TwentyOne.part_two() |> IO.inspect(label: "part 2")
