defmodule DelayEventProducer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def produce_delayed_event_with_notification(producer, key, value, delay) do
    Process.send_after(producer, {:event_notification, key, value}, delay)
  end

  def produce_delayed_event_with_data(producer, key, value, delay) do
    Process.send_after(producer, {:event_data, key, value}, delay)
  end

  def produce_delayed_event_with_data_but_no_save(producer, key, value, delay) do
    Process.send_after(producer, {:event_data_no_save, key, value}, delay)
  end

  def init(%{table: table_name}) do
    {:ok, %{table: table_name}}
  end

  def handle_info({:event_notification, key, value}, state) do
    Barenboim.Cache.Cache.insert(state[:table], {key, value})
    Barenboim.notify({:reference, key})
    {:noreply, state}
  end

  def handle_info({:event_data, key, value}, state) do
    Barenboim.Cache.Cache.insert(state[:table], {key, value})
    Barenboim.notify({:data, key, value})
    {:noreply, state}
  end

  def handle_info({:event_data_no_save, key, value}, state) do
    Barenboim.notify({:data, key, value})
    {:noreply, state}
  end
end

defmodule Helper do
  def get_init_common_data(table_name) do
    Barenboim.Cache.Cache.init_table(table_name, [:named_table, :public])
    fun = fn k -> with [{^k, v}] <- Barenboim.Cache.Cache.get(table_name, k), do: v end
    {:ok, event_producer} = DelayEventProducer.start_link(%{table: table_name})
    {fun, event_producer}
  end
end

ExUnit.start()

