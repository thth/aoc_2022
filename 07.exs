defmodule Seven do
  def part_one(input) do
    input
    |> parse()
    |> build()
    |> list_sizes()
    |> Enum.filter(fn {_k, v} -> v <= 100_000 end)
    |> Enum.reduce(0, fn {_k, v}, acc -> acc + v end)
  end

  def part_two(input) do
    input
    |> parse()
    |> build()
    |> list_sizes()
    |> then(fn size_list ->
      total = 70_000_000
      needed = 30_000_000
      occupied = size_list[["/"]]
      currently_free = total - occupied
      need_to_delete = needed - currently_free

      size_list
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.filter(&(&1 >= need_to_delete))
      |> Enum.min()
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(fn str ->
        case Integer.parse(str) do
          :error -> str
          {n, ""} -> n
        end
      end)
      |> List.to_tuple()
    end)
  end

  defp build(cmds), do: build(cmds, %{}, [])

  defp build([], tree, _), do: tree
  defp build([{"$", "cd", ".."} | rest_cmd], tree, pos), do: build(rest_cmd, tree, Enum.slice(pos, 0..-2))
  defp build([{"$", "cd", "/"} | rest_cmd], tree, _), do: build(rest_cmd, Map.put_new(tree, "/", %{}), ["/"])
  defp build([{"$", "cd", dir} | rest_cmd], tree, pos), do: build(rest_cmd, tree, pos ++ [dir])
  defp build([{"$", "ls"} | rest_cmd], tree, pos), do: build(rest_cmd, tree, pos)
  defp build([{"dir", dir} | rest_cmd], tree, pos),
    do: build(rest_cmd, update_in(tree, pos, &Map.put_new(&1, dir, %{})), pos)
  defp build([{n, file} | rest_cmd], tree, pos),
    do: build(rest_cmd, update_in(tree, pos, &Map.put_new(&1, file, n)), pos)

  defp list_sizes(tree), do: list_sizes(tree, ["/"], %{})
  defp list_sizes(tree, ["/"], sizes) when tree == %{"/" => %{}}, do: sizes
  defp list_sizes(tree, pos, sizes) do
    case tree |> get_in(pos) |> Enum.sort() |> List.first() do
      nil ->
        {%{}, new_tree} = pop_in(tree, pos)
        pos_size = sizes[pos]
        new_sizes = Map.update(sizes, Enum.slice(pos, 0..-2), pos_size, &(&1 + pos_size))
        list_sizes(new_tree, Enum.slice(pos, 0..-2), new_sizes)
      {k, v} when is_integer(v) ->
        {^v, new_tree} = pop_in(tree, pos ++ [k])
        new_sizes = Map.update(sizes, pos, v, &(&1 + v))
        list_sizes(new_tree, pos, new_sizes)
      {k, _v} ->
        list_sizes(tree, pos ++ [k], sizes)
    end
  end
end

input = File.read!("input/07.txt")

input |> Seven.part_one() |> IO.inspect(label: "part 1")
input |> Seven.part_two() |> IO.inspect(label: "part 2")
