defmodule Nineteen do
  defmodule State do
    defstruct [:blueprint, :c_ore, :c_clay, :c_obs, :c_geo,
      r_ore: 1, r_clay: 0, r_obs: 0, r_geo: 0,
      ore: 0, clay: 0, obs: 0, geo: 0, t: 0]
  end
  @t_one 24
  @t_two 32

  # runs in 8s
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn state ->
      Task.async(fn ->
        state
        |> max_geo_in(@t_one)
        |> Kernel.*(state.blueprint)
      end)
    end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.sum()
  end

  # runs in 20s
  def part_two(input) do
    input
    |> parse()
    |> Enum.take(3)
    |> Enum.map(fn state ->
      Task.async(fn ->
        state
        |> max_geo_in(@t_two)
      end)
    end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.product()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/\d+/, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      |> then(fn [b, c_ore, c_clay, c_obs_ore, c_obs_clay, c_geo_ore, c_geo_obs] ->
        %State{
          blueprint: b, c_ore: %{ore: c_ore}, c_clay: %{ore: c_clay},
          c_obs: %{ore: c_obs_ore, clay: c_obs_clay}, c_geo: %{ore: c_geo_ore, obs: c_geo_obs}
        }
      end)
    end)
  end

  defp max_geo_in(state, max_t) do
    memo =
      1..max_t
      |> Enum.map(fn t ->
        [:ore, :r_ore, :clay, :r_clay, :obs, :r_obs, :geo, :r_geo]
        |> Enum.map(fn k -> {k, 0} end)
        |> Enum.into(%{})
        |> then(fn m -> {t, m} end)
      end)
      |> Enum.into(%{})
    max_geo_in([state], memo, 0, max_t)
  end
  defp max_geo_in([], _, max_geo, _), do: max_geo
  defp max_geo_in([%State{t: t, geo: geo} | rest], memo, max_geo, t), do: max_geo_in(rest, memo, max(max_geo, geo), t)
  defp max_geo_in([state | rest], memo, max_geo, t) do
    collects = collect(state)
    {new_memo, nexts} =
      state
      |> builds()
      |> Enum.map(&add_collects(&1, collects))
      |> Enum.reduce({memo, []}, fn state, {memo_acc, add_acc} ->
        if worthy?(state, memo_acc) do
          new_memo_acc = update_memo(state, memo_acc)
          {new_memo_acc, [state | add_acc]}
        else
          {memo_acc, add_acc}
        end
      end)
    max_geo_in(nexts ++ rest, new_memo, max_geo, t)
  end

  defp worthy?(state, memos) do
    max_ore_cost = [state.c_ore.ore, state.c_clay.ore, state.c_obs.ore, state.c_geo.ore] |> Enum.max()
    memo = memos[state.t]
    prev = memos[state.t - 1] || ([:ore, :r_ore, :clay, :r_clay, :obs, :r_obs, :geo, :r_geo]
    |> Enum.map(fn k -> {k, -1} end)
    |> Enum.into(%{}))

    more_than_prev? =
      state.r_geo > prev.r_geo
      or state.r_obs > prev.r_obs
      or state.r_clay > prev.r_clay
      or state.r_ore > prev.r_ore
      or (state.ore >= prev.ore and state.r_ore < max_ore_cost)
      or (state.clay >= prev.clay and state.r_clay < state.c_obs.clay)
      or (state.obs >= prev.obs and state.r_obs < state.c_geo.obs)
      or state.geo > prev.geo
      or (state.geo == prev.geo and state.r_obs == prev.r_obs)

    more_robots? =
      state.r_geo >= memo.r_geo
      or state.r_obs >= memo.r_obs
      or state.r_clay >= memo.r_clay
      or state.r_ore >= memo.r_ore

    more_resources? =
      (state.ore >= memo.ore and state.r_ore < max_ore_cost)
      or (state.clay >= memo.clay and state.r_clay < state.c_obs.clay)
      or (state.obs >= memo.obs and state.r_obs < state.c_geo.obs)
      or state.geo >= memo.geo

    more_than_prev? and (more_robots? or more_resources?)
  end

  defp update_memo(state, memo) do
    Map.update!(memo, state.t, fn old ->
      Enum.map(old, fn {k, n} ->
        {k, max(n, Map.get(state, k))}
      end)
      |> Enum.into(%{})
    end)
  end

  defp collect(state) do
    [ore: state.r_ore, clay: state.r_clay, obs: state.r_obs, geo: state.r_geo]
  end

  defp add_collects(state, collects) do
    Enum.reduce(collects, state, fn {material, n}, acc ->
      Map.update!(acc, material, &(&1 + n))
    end)
  end

  defp builds(state) do
    max_ore_cost = [state.c_ore.ore, state.c_clay.ore, state.c_obs.ore, state.c_geo.ore] |> Enum.max()

    [r_ore: state.c_ore, r_clay: state.c_clay, r_obs: state.c_obs, r_geo: state.c_geo]
    |> Enum.reject(fn
      {:r_ore, _} when state.r_ore >= max_ore_cost -> true
      {:r_clay, _} when state.r_clay >= state.c_obs.clay -> true
      {:r_obs, _} when state.r_obs >= state.c_geo.obs -> true
      {_, costs} ->
        Enum.any?(costs, fn {material, n} -> Map.get(state, material) < n end)
    end)
    |> Enum.map(fn {robot, costs} ->
      Enum.reduce(costs, state, fn {material, n}, acc -> Map.update!(acc, material, &(&1 - n)) end)
      |> Map.update!(robot, &(&1 + 1))
    end)
    |> then(fn builts ->
      if state.r_ore < max_ore_cost, do: [state | builts], else: builts
    end)
    |> Enum.map(fn state -> Map.update!(state, :t, &(&1 + 1)) end)
  end
end

input = File.read!("input/19.txt")

input |> Nineteen.part_one() |> IO.inspect(label: "part 1")
input |> Nineteen.part_two() |> IO.inspect(label: "part 2")
