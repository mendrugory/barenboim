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
    assert Barenboim.get_data(1, fun) == {:ok, 2}
  end

  test "wait for a notification of an event which will arrive in 5 seconds" do
    table_name = :test2
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event_with_notification(event_producer, 2, 3, 5000)
    assert Barenboim.get_data(2, fun) == {:ok, 3}
  end

  test "wait for a notification of an event which will arrive in 10 seconds" do
    table_name = :test3
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event_with_notification(event_producer, 3, 4, 10000)
    assert Barenboim.get_data(3, fun) == {:ok, 4}
  end

  test "wait 3 seconds for a notification of an event which will arrive in 5 seconds" do
    table_name = :test4
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event_with_notification(event_producer, 4, 5, 5000)
    assert Barenboim.get_data(4, fun, 3000) == {:time_out, []}
  end

  test "wait 5 seconds for an event which will never arrive" do
    table_name = :test5
    {fun, _event_producer} = Helper.get_init_common_data(table_name)
    assert Barenboim.get_data(9999, fun, 5000) == {:time_out, []}
  end

  test "wait for the data of an event which will arrive in 5 seconds" do
    table_name = :test6
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event_with_data(event_producer, 5, 6, 5000)
    assert Barenboim.get_data(5, fun) == {:ok, 6}
  end

  test "wait for the data of an event which will arrive in 10 seconds" do
    table_name = :test7
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event_with_data(event_producer, 6, 7, 10000)
    assert Barenboim.get_data(6, fun) == {:ok, 7}
  end

  test "wait 3 seconds for the data of an event which will arrive in 5 seconds" do
    table_name = :test8
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event_with_data(event_producer, 7, 8, 5000)
    assert Barenboim.get_data(7, fun, 3000) == {:time_out, []}
  end

  test "notification between the data checking and the dependency adding" do
    table_name = :test9
    {fun, event_producer} = Helper.get_init_common_data(table_name)
    DelayEventProducer.produce_delayed_event_with_data_but_no_save(event_producer, 8, 9, 100)
    Process.sleep(110)
    assert Barenboim.get_data(8, fun) == {:ok, 9}
  end


end
