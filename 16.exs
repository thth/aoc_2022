defmodule Sixteen do
  def part_one(input) do
    map = parse(input)
    nodes =
      map
      |> Enum.filter(fn {valve, %{flow: flow}} -> valve == "AA" or flow > 0 end)
      |> Enum.map(&elem(&1, 0))
    distances = find_distances(nodes, map)

    find_pressure(nodes -- ["AA"], map, distances)
  end

  def part_two(input) do
    map = parse(input)
    nodes =
      map
      |> Enum.filter(fn {valve, %{flow: flow}} -> valve == "AA" or flow > 0 end)
      |> Enum.map(&elem(&1, 0))
      distances = find_distances(nodes, map)

    # this took 2 hours to run and all my RAM such that even opening my browser crashed it
    elephant(nodes -- ["AA"], map, distances)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/[A-Z]{2}|\d+/, line)
      |> List.flatten()
      |> then(fn [valve, flow | tunnels] ->
        {valve, %{flow: String.to_integer(flow), tunnels: tunnels}}
      end)
    end)
    |> Enum.into(%{})
  end

  defp find_distances(flowing, map), do: find_distances(Enum.sort(flowing), map, %{})
  defp find_distances([_], _, distances), do: distances
  defp find_distances([valve | rest], map, distances) do
    new_distances = Enum.reduce(rest, distances, fn dest, acc ->
      Map.put(acc, {valve, dest}, distance_between(valve, dest, map))
    end)
    find_distances(rest, map, new_distances)
  end

  defp distance_between(a, b, map), do: distance_between([a], b, map, MapSet.new([a]), 0)
  defp distance_between(list, dest, map, seen, distance) do
    if dest in list do
      distance
    else
      {new_list, new_seen} =
        Enum.reduce(list, {[], seen}, fn valve, {acc_list, seeing} ->
          connections =
            map[valve][:tunnels]
            |> MapSet.new()
            |> MapSet.difference(seeing)

          {Enum.to_list(connections) ++ acc_list, MapSet.union(seeing, connections)}
        end)
      distance_between(new_list, dest, map, new_seen, distance + 1)
    end
  end

  defp elephant(nodes, map, distances), do:  elephant("AA", "AA", nodes, map, distances, 0, 26, 26)
  defp elephant(_, _, _, _, _, p, ta, tb) when ta <= 0 and tb <= 0, do: p
  defp elephant(_, _, [], _, _, p, _, _), do: p
  defp elephant(a, nil, nodes_left, map, distances, p, ta, tb) when tb <= 0 do
    find_pressure(a, nodes_left, map, distances, p, ta)
  end
  defp elephant(nil, b, nodes_left, map, distances, p, ta, tb) when ta <= 0 do
    find_pressure(b, nodes_left, map, distances, p, tb)
  end
  defp elephant(a, b, nodes_left, map, distances, p, ta, tb) do
    {next_a, next_b} =
      elephant_permutations(nodes_left)
      |> Stream.map(fn {ap, bp} ->
        {Enum.chunk_every([a | ap], 2, 1, :discard), Enum.chunk_every([b | bp], 2, 1, :discard)}
      end)
      |> Enum.reduce({nil, 0}, fn {a_path, b_path}, {path_acc, max_acc} ->
        ap =
          Enum.reduce(a_path, {0, ta}, fn [from, to], {p_acc, t_acc} ->
            new_p = p_acc + add_pressure(from, to, distances, map, max(0, t_acc))
            new_t = t_acc - find_distance(from, to, distances) - 1
            {new_p, new_t}
          end)
          |> elem(0)
        bp =
          Enum.reduce(b_path, {0, tb}, fn [from, to], {p_acc, t_acc} ->
            new_p = p_acc + add_pressure(from, to, distances, map, max(0, t_acc))
            new_t = t_acc - find_distance(from, to, distances) - 1
            {new_p, new_t}
          end)
          |> elem(0)
        if ap + bp > max_acc, do: {{a_path, b_path}, ap + bp}, else: {path_acc, max_acc}
      end)
      |> elem(0)
      |> then(fn {a_path, b_path} ->
        cond do
          Enum.count(b_path) == 0 -> {Enum.at(Enum.at(a_path, 0), 1), nil}
          Enum.count(a_path) == 0 -> {nil, Enum.at(Enum.at(b_path, 0), 1)}
          true -> {Enum.at(Enum.at(a_path, 0), 1), Enum.at(Enum.at(b_path, 0), 1)}
        end
      end)
    cond do
      is_nil(next_a) ->
        new_p = p + add_pressure(b, next_b, distances, map, max(0, tb))
        new_tb = tb - find_distance(b, next_b, distances) - 1
        elephant(nil, next_b, nodes_left -- [next_b], map, distances, new_p, 0, new_tb)
      is_nil(next_b) ->
        new_p = p + add_pressure(a, next_a, distances, map, max(0, ta))
        new_ta = ta - find_distance(a, next_a, distances) - 1
        elephant(next_a, nil, nodes_left -- [next_a], map, distances, new_p, new_ta, 0)
      true ->
        new_p = p + add_pressure(a, next_a, distances, map, max(0, ta)) + add_pressure(b, next_b, distances, map, max(0, tb))
        new_ta = ta - find_distance(a, next_a, distances) - 1
        new_tb = tb - find_distance(b, next_b, distances) - 1
        elephant(next_a, next_b, nodes_left -- [next_a, next_b], map, distances, new_p, new_ta, new_tb)
    end
  end

  defp find_pressure(nodes, map, distances), do: find_pressure("AA", nodes, map, distances, 0, 30)
  defp find_pressure(_, _, _, _, pressure, t) when t <= 0, do: pressure
  defp find_pressure(_, [], _, _, pressure, _), do: pressure
  defp find_pressure(last, nodes_left, map, distances, pressure, t) do
    next =
      limited_permutations(nodes_left)
      |> Enum.map(fn perms -> Enum.chunk_every([last | perms], 2, 1, :discard) end)
      |> Enum.max_by(fn path ->
        Enum.reduce(path, {0, t}, fn [from, to], {p_acc, t_acc} ->
          new_p = p_acc + add_pressure(from, to, distances, map, max(0, t_acc))
          new_t = t_acc - find_distance(from, to, distances) - 1
          {new_p, new_t}
        end)
        |> elem(0)
      end)
      |> hd()
      |> Enum.at(1)
    new_pressure = pressure + add_pressure(last, next, distances, map, max(0, t))
    new_t = t - find_distance(last, next, distances) - 1
    find_pressure(next, nodes_left -- [next], map, distances, new_pressure, new_t)
  end

  defp find_distance(from, to, distances) do
    Enum.sort([from, to])
    |> List.to_tuple()
    |> then(&Map.get(distances, &1))
  end

  defp add_pressure(from, to, distances, map, t_left) do
    distance = find_distance(from, to, distances)
    max(0, t_left - distance - 1) * map[to][:flow]
  end

  defp limited_permutations([a]), do: [[a]]
  defp limited_permutations([a, b]), do: [[a, b], [b, a]]
  defp limited_permutations([a, b, c]), do: [[a, b, c], [a, c, b], [b, a, c], [b, c, a], [c, a, b], [c, b, a]]
  defp limited_permutations(list) do
    for a <- list,
        b <- list -- [a],
        c <- list -- [a, b],
        d <- list -- [a, b, c] do
      [a, b, c, d]
    end
  end

  def elephant_permutations(list) do
    #            「"BLOOD FOR THE BLOOD GOD"」
    #            /
    #         🐘
    Stream.flat_map(list, fn a ->
      for i <- [nil | list -- [a]],
          b <- [nil | list -- [a, i]],
          j <- [nil | list -- [a, i, b]],
          c <- [nil | list -- [a, i, b, j]],
          k <- [nil | list -- [a, i, b, j, c]],
          d <- [nil | list -- [a, i, b, j, c, k]],
          l <- [nil | list -- [a, i, b, j, c, k, d]] do
        {Enum.reject([a, b, c, d], &is_nil/1), Enum.reject([i, j, k, l], &is_nil/1)}
      end
    end)
  end
end

input = File.read!("input/16.txt")

input |> Sixteen.part_one() |> IO.inspect(label: "part 1")
input |> Sixteen.part_two() |> IO.inspect(label: "part 2")
