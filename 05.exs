defmodule Five do
  def part_one(input) do
    {crates, steps} = parse(input)

    run(crates, steps, &crate_mover_9000/2)
    |> Enum.map(&List.first/1)
    |> Enum.join()
  end

  def part_two(input) do
    {crates, steps} = parse(input)

    run(crates, steps, &crate_mover_9001/2)
    |> Enum.map(&List.first/1)
    |> Enum.join()
  end

  defp parse(text) do
    [crates, steps] = String.split(text, ~r/\R\R/)

    crates =
      crates
      |> String.split(~r/\R/)
      |> Enum.map(&String.graphemes/1)
      |> Enum.zip()
      |> List.delete_at(0)
      |> Enum.take_every(4)
      |> Enum.map(fn pile ->
        pile
        |> Tuple.to_list()
        |> Enum.reject(&(&1 == " "))
      end)

    steps =
      steps
      |> String.trim()
      |> String.split(~r/\R/)
      |> Enum.map(fn step ->
        Regex.scan(~r/\d+/, step)
        |> Enum.map(fn [n] -> String.to_integer(n) end)
        |> then(fn [n, a, b] -> {n, a - 1, b - 1} end)
      end)

    {crates, steps}
  end

  defp run(crates, [], _), do: crates
  defp run(crates, [step | rest], crate_mover) do
    crate_mover.(crates, step)
    |> run(rest, crate_mover)
  end

  defp crate_mover_9000(crates, {0, _, _}), do: crates
  defp crate_mover_9000(crates, {n, a, b}) do
    crate = crates |> Enum.at(a) |> Enum.at(0)

    new_crates =
      crates
      |> List.update_at(a, fn [_| rest] -> rest end)
      |> List.update_at(b, fn list -> [crate | list] end)

    crate_mover_9000(new_crates, {n - 1, a, b})
  end

  defp crate_mover_9001(crates, {n, a, b}) do
    {to_move, rest} = crates |> Enum.at(a) |> Enum.split(n)

    crates
    |> List.update_at(a, fn _ -> rest end)
    |> List.update_at(b, fn list -> to_move ++ list end)
  end
end

input = File.read!("input/05.txt")

input |> Five.part_one() |> IO.inspect(label: "part 1")
input |> Five.part_two() |> IO.inspect(label: "part 2")
