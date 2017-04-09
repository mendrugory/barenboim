defmodule Barenboim.Workers.Worker do
  @moduledoc false
  
  use GenServer
  alias Barenboim.Cache.Dependencies


  @second_notification_delay            100


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
    reminder_time = Application.get_env(:barenboim, :reminder_time) || @second_notification_delay
    {:ok, %{reminder_time: reminder_time}}
  end

  def handle_cast({:add, dependency, dependent, time_to_live}, state) do
    unless is_nil(time_to_live), do: Process.send_after(self(), {:delete, dependency}, time_to_live)
    Task.Supervisor.start_child(
      Barenboim.Workers.WorkerTaskSupervisor,
      fn -> add(dependency, dependent) end
    )
    {:noreply, state}
  end

  def handle_cast({:ready, dependency}, %{reminder_time: reminder_time} = state) do
    Process.send_after(self(), {:ready, dependency}, reminder_time)
    Task.Supervisor.start_child(
      Barenboim.Workers.WorkerTaskSupervisor,
      fn -> ready(dependency) end
    )
    {:noreply, state}
  end

  def handle_info({:ready, dependency}, state) do
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

  defp add(dependency, dependent) do
    Dependencies.insert(dependency, dependent)
  end

  defp ready({:data, dependency_ref, _dependency_data} = dependency) do
    communicate_dependents(dependency_ref, dependency)
  end

  defp ready({:reference, dependency_ref} = dependency) do
    communicate_dependents(dependency_ref, dependency)
  end

  defp communicate_dependents(dependency_ref, communication_data) do
    dependency_ref
    |> Dependencies.get_dependents()
    |> Enum.each(fn dependent -> send(dependent, {:ready, communication_data}) end)
    delete(dependency_ref)
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