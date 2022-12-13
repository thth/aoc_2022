defmodule Thirteen do
  def part_one(input) do
    input
    |> parse()
    |> Enum.with_index(1)
    |> Enum.filter(fn {pair, _} -> in_order?(pair) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()

  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.reduce([[[2]], [[6]]], fn {l, r}, acc -> [l, r | acc] end)
    |> Enum.sort(&in_order?/2)
    |> Enum.with_index(1)
    |> then(fn ordered ->
      {_, a} = Enum.find(ordered, fn {p, _} -> p == [[2]] end)
      {_, b} = Enum.find(ordered, fn {p, _} -> p == [[6]] end)
      a * b
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> Enum.map(fn pair ->
      pair
      |> String.split(~r/\R/, trim: true)
      |> Enum.map(fn str ->
        str
        |> Code.eval_string()
        |> elem(0)
      end)
      |> List.to_tuple()
    end)
  end

  defp in_order?({left, right}), do: in_order?(left, right)

  defp in_order?([l | _], [r | _]) when is_integer(l) and is_integer(r) and l < r, do: true
  defp in_order?([l | _], [r | _]) when is_integer(l) and is_integer(r) and l > r, do: false
  defp in_order?([], []), do: :cont
  defp in_order?([l | rl], [r | rr]) when l == r, do: in_order?(rl, rr)
  defp in_order?([l | rl], [r | rr]) when is_list(l) and is_list(r) do
    case in_order?(l, r) do
      :cont -> in_order?(rl, rr)
      ordered -> ordered
    end
  end
  defp in_order?([l | rl], [r | rr]) when is_list(l), do: in_order?([l | rl], [[r] | rr])
  defp in_order?([l | rl], [r | rr]) when is_list(r), do: in_order?([[l] | rl], [r | rr])
  defp in_order?([], _), do: true
  defp in_order?(_, []), do: false
end

input = File.read!("input/13.txt")

input |> Thirteen.part_one() |> IO.inspect(label: "part 1")
input |> Thirteen.part_two() |> IO.inspect(label: "part 2")
