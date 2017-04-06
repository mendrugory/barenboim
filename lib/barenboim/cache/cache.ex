defmodule Barenboim.Cache.Cache do
  @moduledoc false

  @doc """
  It creates a new ets table
  """
  def init_table(table_name, args \\ [:named_table, :public]) do
    :ets.new(table_name, args)
  end

  @doc """
  It gets all the keys of the given table
  """
  def keys(table_name) do
    key = :ets.first(table_name)
    keys(table_name, key, [])
  end

  def keys(_table_name, :"$end_of_table", acc) do
    acc
  end

  def keys(table_name, key, acc) do
    next_key = :ets.next(table_name, key)
    keys(table_name, next_key, [key | acc])
  end

  @doc """
  It inserts a new register in the given table
  """
  def insert(table_name, register) do
    :ets.insert(table_name, register)
  end

  @doc """
  It gets the registers from the given table which the given key
  """
  def get(table_name, key) do
    :ets.lookup(table_name, key)
  end


  @doc """
  It deletes the registers from the given table which the given list of keys/ids
  """
  def delete(table_name, [key | tail_keys]) when is_list(tail_keys) do
    unless Enum.empty?(tail_keys) do
      delete(table_name, tail_keys)
    end
    delete(table_name, key)
  end

  @doc """
  It deletes the register from the given table which the given key/id
  """
  def delete(table_name, key) do
    :ets.delete(table_name, key)
  end

  @doc """
  It deletes all the data. Clean the table.
  """
  def clean_table(table_name) do
    delete(table_name, keys(table_name))
  end

end