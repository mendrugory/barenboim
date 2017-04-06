defmodule CacheTest do
  use ExUnit.Case

  alias Barenboim.Cache.Dependencies

  setup do
    if Dependencies.clean_table(), do: :ok, else: :error
  end

  test "insert dependency" do
    assert Dependencies.insert(1, 2) == true
  end

  test "remove one dependency" do
    assert Dependencies.insert(1, 2) == true
    assert Dependencies.delete(1) == true
  end

  test "get dependendents" do
    assert Dependencies.insert(1, 2) == true
    assert Dependencies.get_dependents(1) == [2]
  end

  test "get all dependencies" do
    numbers = 1..10
    for i <- numbers, do: Dependencies.insert(i, i + 3)
    assert Dependencies.get_all_dependencies() |> Enum.sort == numbers |> Enum.to_list()
  end

  test "remove several dependencies" do
    for i <- 1..10, do: Dependencies.insert(i, i + 3)
    assert Dependencies.delete(Enum.to_list(1..5)) == true
  end

  test "clean table" do
    for i <- 1..10, do: Dependencies.insert(i, i + 3)
    assert Dependencies.clean_table() == true
  end

end
