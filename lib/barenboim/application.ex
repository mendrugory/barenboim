defmodule Barenboim.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Barenboim.Cache.Supervisor, [[name: Barenboim.Cache.Supervisor]]),
      worker(Barenboim.Workers.Supervisor, [[name: Barenboim.Workers.Supervisor]]),
      :poolboy.child_spec(:worker, poolboy_config(), [])
    ]

    opts = [strategy: :one_for_one, name: Barenboim.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp poolboy_config() do
    worker_module = Barenboim.Workers.Worker
    domain = Application.get_env(:barenboim, :pool_domain) || :local
    pool_size = Application.get_env(:barenboim, :pool_size) || 10
    max_overflow = Application.get_env(:barenboim, :pool_size) || 5
    [
      {:name, {domain, :barenboim_pool}},
      {:worker_module, worker_module},
      {:size, pool_size},
      {:max_overflow, max_overflow}
    ]
  end
end
