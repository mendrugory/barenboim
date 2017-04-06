defmodule BarenboimTest do
  use ExUnit.Case
  doctest Barenboim

  alias Barenboim.Cache.Dependencies

  setup do
    if Dependencies.clean_table(), do: :ok, else: :error
  end

  test "get ready data" do
    table_name = :test1
    {fun, _event_producer} = Helper.get_init_common_data(table_name)
    Barenboim.Cache.Cache.insert(table_name, {1, 2})
    assert Barenboim.get_data(1, fun) == {:ok, [{1, 2}]}
  end

  test "wait for an event which will arrive in 5 seconds" do
    table_name = :test2
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event(event_producer, 1, 2, 5000)
    assert Barenboim.get_data(1, fun) == {:ok, [{1, 2}]}
  end

  test "wait for an event which will arrive in 10 seconds" do
    table_name = :test3
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event(event_producer, 1, 2, 10000)
    assert Barenboim.get_data(1, fun) == {:ok, [{1, 2}]}
  end

  test "wait 3 seconds for an event which will arrive in 5 seconds" do
    table_name = :test4
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event(event_producer, 1, 2, 5000)
    assert Barenboim.get_data(1, fun, 3000) == {:time_out, []}
  end

  test "wait 5 seconds for an event which will never arrive" do
    table_name = :test5
    {fun, _event_producer} = Helper.get_init_common_data(table_name)
    assert Barenboim.get_data(1, fun, 5000) == {:time_out, []}
  end


end
