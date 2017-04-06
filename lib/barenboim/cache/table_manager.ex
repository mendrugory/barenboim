defmodule Barenboim.Cache.TableManager do
  @moduledoc false

  use GenServer
  alias Barenboim.Cache

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts ++ [name: __MODULE__])
  end

  def init(_opts) do
    Cache.Dependencies.init_table()
    {:ok, %{}}
  end

end