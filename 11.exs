defmodule Eleven do
  defmodule Monkey do
    defstruct [:monkey_n, :items, :operation, :test, :if_true, :if_false, :inspects]
  end

  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&run_one/1)
    |> Enum.at(20)
    |> Enum.sort_by(&(&1.inspects), &>/2)
    |> Enum.take(2)
    |> Enum.map(&(&1.inspects))
    |> Enum.product()
  end

  def part_two(input) do
    input
    |> parse()
    |> Stream.iterate(&run_two/1)
    |> Enum.at(10_000)
    |> Enum.sort_by(&(&1.inspects), &>/2)
    |> Enum.take(2)
    |> Enum.map(&(&1.inspects))
    |> Enum.product()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> Enum.map(fn monkey ->
      [[monkey_n], items, [_ | op], [test], [if_true], [if_false]] =
        monkey
        |> String.split(~r/\R/, trim: true)
        |> Enum.map(fn line ->
            Regex.scan(~r/\d+|old|\+|\*/, line)
            |> List.flatten()
        end)
        |> Enum.map(&Enum.map(&1, fn x ->
          case Integer.parse(x) do
            {n, _} -> n
            :error -> x
          end
        end))
      %Monkey{
        monkey_n: monkey_n,
        items: items,
        operation: op,
        test: test,
        if_true: if_true,
        if_false: if_false,
        inspects: 0
      }
    end)
  end

  defp run_one(monkeys), do: run_one(monkeys, 0, length(monkeys))
  defp run_one(monkeys, n, n), do: monkeys
  defp run_one(monkeys, n, total) do
    {new_monkey, throws} =
      monkeys
      |> Enum.at(n)
      |> inspect_items()
      |> reduce_worry()
      |> throw_items()
    new_monkeys = update_monkeys(monkeys, throws, new_monkey, n)
    run_one(new_monkeys, n + 1, total)
  end

  defp run_two(monkeys), do: run_two(monkeys, 0, length(monkeys))
  defp run_two(monkeys, n, n), do: monkeys
  defp run_two(monkeys, n, total) do
    product = monkeys |> Enum.map(&(&1.test)) |> Enum.product()
    {new_monkey, throws} =
      monkeys
      |> Enum.at(n)
      |> inspect_items()
      |> worry_management(product)
      |> throw_items()
    new_monkeys = update_monkeys(monkeys, throws, new_monkey, n)
    run_two(new_monkeys, n + 1, total)
  end

  defp inspect_items(%Monkey{items: items, operation: operation, inspects: inspects} = monkey) do
    new_items =
      case operation do
        ["+", n] -> Enum.map(items, &(&1 + n))
        ["*", "old"] -> Enum.map(items, &(&1 * &1))
        ["*", n] -> Enum.map(items, &(&1 * n))
      end
    %Monkey{monkey | items: new_items, inspects: inspects + length(items)}
  end

  defp reduce_worry(%Monkey{items: items} = monkey) do
    %Monkey{monkey | items: Enum.map(items, &div(&1, 3))}
  end

  defp throw_items(%Monkey{items: items, test: test, if_true: if_true, if_false: if_false} = monkey) do
    throws = Enum.map(items, fn item ->
      {(if rem(item, test) == 0, do: if_true, else: if_false), item}
    end)
    {%Monkey{monkey | items: []}, throws}
  end

  defp worry_management(%Monkey{items: items} = monkey, product) do
    %Monkey{monkey | items: Enum.map(items, &rem(&1, product))}
  end

  defp update_monkeys(monkeys, throws, new_monkey, n) do
    monkeys
    |> List.replace_at(n, new_monkey)
    |> then(fn monkeys_list ->
      Enum.reduce(throws, monkeys_list, fn {target, item}, acc ->
        List.update_at(acc, target, fn monkey -> Map.update!(monkey, :items, fn item_list -> item_list ++ [item] end) end)
      end)
    end)
  end
end

input = File.read!("input/11.txt")

input |> Eleven.part_one() |> IO.inspect(label: "part 1")
input |> Eleven.part_two() |> IO.inspect(label: "part 2")
