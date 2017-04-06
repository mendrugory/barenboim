defmodule Barenboim.Workers.Worker do
  @moduledoc false
  
  use GenServer
  alias Barenboim.Cache.Dependencies


  #######
  # API #
  #######

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end


  #############
  # CALLBACKS #
  #############

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:add, depend, dependent, time_to_live}, state) do
    unless is_nil(time_to_live), do: Process.send_after(self(), {:delete, depend}, time_to_live)
    Task.Supervisor.start_child(
      Barenboim.Workers.WorkerTaskSupervisor,
      fn -> add(depend, dependent) end
    )
    {:noreply, state}
  end

  def handle_cast({:ready, dependency}, state) do
    Task.Supervisor.start_child(
      Barenboim.Workers.WorkerTaskSupervisor,
      fn -> ready(dependency) end
    )
    {:noreply, state}
  end

  def handle_info({:delete, dependency}, state) do
    Task.Supervisor.start_child(
      Barenboim.Workers.WorkerTaskSupervisor,
      fn -> delete(dependency) end
    )
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end


  ###########
  # PRIVATE #
  ###########

  defp add([dependency | dependencies], dependent) do
    add(dependency, dependent)
    add(dependencies, dependent)
  end

  defp add([], _dependent) do
    :empty
  end

  defp add(dependency, dependent) do
    Dependencies.insert(dependency, dependent)
  end

  defp ready(dependency) do
    dependents = Dependencies.get_dependents(dependency)
    Enum.each(dependents, fn dependent -> send(dependent, {:ready, dependency}) end)
    delete(dependency)
  end

  defp delete([dependency | dependencies]) do
    delete(dependency)
    delete(dependencies)
  end

  defp delete([]) do
    :empty
  end

  defp delete(dependency) do
    Dependencies.delete(dependency)
  end

end