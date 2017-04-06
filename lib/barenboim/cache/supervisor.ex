defmodule Barenboim.Cache.Supervisor do
  @moduledoc false
  
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    children = [
      worker(Barenboim.Cache.TableManager, [[], []])
    ]

    supervise(children, strategy: :one_for_one)
  end
end