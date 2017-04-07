defmodule Barenboim.Cache.Dependencies do
  @moduledoc false

  alias Barenboim.Cache.Cache

  @table_name :barenboim_dependencies

  @doc """
  It returns a list with all the dependencies
  """
  def get_all_dependencies() do
    @table_name
    |> Cache.keys()
    |> Enum.uniq()
  end

  @doc """
  It initializes the table for the dependencies
  """
  def init_table do
    Cache.init_table(@table_name, [:named_table, :public, :bag])
  end

  @doc """
  It inserts a new dependency
  """
  def insert(dependency, dependent) do
     Cache.insert(@table_name, {dependency, dependent})
  end

  @doc """
  It deletes all the given dependency/dependencies.
  *depend* can be a dependency or a list of dependencies.
  """
  def delete(depend) do
     Cache.delete(@table_name, depend)
  end

  @doc """
  It gets all the dependents of a given dependency
  """
  def get_dependents(dependency) do
    Cache.get(@table_name, dependency)
    |> Enum.map(fn {_dependency, dependent} -> dependent end)
  end

  @doc"""
  It deletes all the data.
  """
  def clean_table() do
    Cache.clean_table(@table_name)
  end
end