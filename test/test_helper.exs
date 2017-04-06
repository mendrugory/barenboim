defmodule DelayEventProducer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def produce_delayed_event(producer, key, value, delay) do
    Process.send_after(producer, {:event, key, value}, delay)
  end

  def init(%{table: table_name}) do
    {:ok, %{table: table_name}}
  end

  def handle_info({:event, key, value}, state) do
    Barenboim.Cache.Cache.insert(state[:table], {key, value})
    Barenboim.ready(key)
    {:noreply, state}
  end
end

defmodule Helper do
  def get_init_common_data(table_name) do
    Barenboim.Cache.Cache.init_table(table_name, [:named_table, :public])
    fun = fn(k)-> Barenboim.Cache.Cache.get(table_name, k) end
    {:ok, event_producer} = DelayEventProducer.start_link(%{table: table_name})
    {fun, event_producer}
  end
end

ExUnit.start()
