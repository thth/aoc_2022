defmodule Ten do
  def part_one(input) do
    input
    |> parse()
    |> run()
    |> Enum.filter(fn {k, _} -> k in [20, 60, 100, 140, 180, 220] end)
    |> Enum.map(fn {k, v} -> k * v end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> run()
    |> Enum.sort()
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.map(&1, fn {k, v} -> rem(k - 1, 40) in (v-1)..(v+1) end))
    |> Enum.each(fn line ->
      Enum.each(line, fn p -> if p, do: IO.write("#"), else: IO.write(".") end)
      IO.write("\n")
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn
      "noop" -> :noop
      "addx " <> n -> {:addx, String.to_integer(n), 2}
    end)
  end

  defp run(steps), do: run(steps, 1, 1, %{})
  defp run([], _, _, values), do: values
  defp run([:noop | rest], cycle, x, values), do: run(rest, cycle + 1, x, Map.put(values, cycle, x))
  defp run([{:addx, v, 0} | rest], cycle, x, values),
    do: run(rest, cycle, x + v, Map.put(values, cycle, x + v))
  defp run([{:addx, v, n} | rest], cycle, x, values),
    do: run([{:addx, v, n - 1} | rest], cycle + 1, x, Map.put(values, cycle, x))
end

input = File.read!("input/10.txt")

input |> Ten.part_one() |> IO.inspect(label: "part 1")
input |> Ten.part_two() |> IO.inspect(label: "part 2")
