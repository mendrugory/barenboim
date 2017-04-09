defmodule Barenboim do
  @moduledoc """
  `Barenboim` is prepared to tackle with data streaming dependencies in concurrent flows.

  If your application works with a data streaming and your incoming events could have dependencies between them, the app can have problems about when the
  dependency data is ready. Reasons:
  * The Application which is sending the data is not sending the data in the right order
  * Your Application is treating the data concurrently therefore the order is not ensured.


  ### Configuration
  `Barenboim` uses [poolboy](https://github.com/devinus/poolboy) and you can configure it depending on your needs:

  ```elixir
  config :barenboim,
    pool_domain: :global,     # default :local
    pool_size: 20,            # default 10
    max_overflow: 3           # default 5
  ```

  You can also configure a delay for a reminder notification. A reminder notification is sent in order to
  avoid corner cases (notification between the data access and the registration of a dependency).
  This time (milliseconds) should be defined depending on your data access function time (see next section).

  ```elixir
  config :barenboim,
    reminder_time: 50     # default 100
  ```

  ### How to use it
  Define the function that will retrieve the dependency data where `dependency_id` is the id of your data
  and call `Barenboim.get_data`. You can also specify a time out in milliseconds.
  ```elixir
  fun = fn(dependency_id) -> MyDataModule.get(dependency_id) end
  {:ok, data} = Barenboim.get_data(dependency_id, fun)
  ```

  Meanwhile, the flow that is processing a new event has to `notify` when the data is available for others:
  ```elixir
  Barenboim.notify({:referece, dependency_id})
  ```
  Or you can even attach the data:
  ```elixir
  Barenboim.notify({:data, dependency_id, dependency_data})
  ```
  """



  require Logger


  @time_out             1000


  @doc """
  It has to be called when the data dependency is ready to be used by its dependents.

  The argument can be the reference of the dependency or a tuple with the reference of the dependency and
  the dependency data.
  """
  @spec notify({:reference, any} | {:data, any, any}) :: any
  def notify(dependency) do
    :poolboy.transaction(:barenboim_pool, fn pid -> GenServer.cast(pid, {:ready, dependency}) end)
  end


  @doc """
  This function will return the dependency data when is ready.

  * `dependency_id` is the reference of the dependency data
  * `fun` is the function that will get the dependency data. If you don't need the data in that moment, only ensure that the data is ready,
  your `fun` function could only be a data checker `fn(dependency) -> MyDataModule.exist(dependency) end`. `Barenboim` will consider a ready data
  when executing `fun` it retrieves a value different than:
    * `nil`
    * `false`
    * `[]` *empty list*
    * `{}` *empty tuple*
    * `%{}` *empty map*

    If some of these values are valid for your application, use encapsulation in your function, example: `{:ok, []}`
  * if `time_to_live` is a valid integer, `Barenboim` will only wait for the data these milliseconds. If the value does not arrive before the time out,
  it will return `{:timeout, data}` where data will be the returned data of `fun` at that moment. If no `time_to_live` is specified, or a not valid one,
  `Barenboim` will wait until the event arrives.

  ```elixir
  fun = fn(dependency_id) -> MyDataModule.get(dependency_id) end
  case Barenboim.get_data(dependency_id, fun) do
    {:ok, data} -> process(data)
    {:timeout, empty_data} -> go_on()
  end
  ```
  """
  @spec get_data(any, ((any) -> any), integer | nil) :: {:ok, any} | {:timeout, any}
  def get_data(dependency_id, fun, time_to_live \\ nil) do
    data = fun.(dependency_id)
    if is_data(data), do: {:ok, data}, else: wait_and_get(dependency_id, fun, time_to_live)
  end


  ##########
  # PRIVATE#
  ##########

  defp wait_and_get(dependency, fun, time_to_live) when is_integer(time_to_live) do
    add(dependency, time_to_live)
    recv(dependency, fun, time_to_live, false)
  end

  defp wait_and_get(dependency, fun, _time_to_live) do
    add(dependency)
    recv(dependency, fun, @time_out, true)
  end


  defp add(depend, time_to_live \\ nil) do
    :poolboy.transaction(:barenboim_pool, fn pid -> GenServer.cast(pid, {:add, depend, self(), time_to_live}) end)
  end

  defp recv(dependency, fun, time_out, waiting_forever) do
    receive do
      {:ready, {:reference, ^dependency}} -> {:ok, fun.(dependency)}
      {:ready, {:data, ^dependency, dependency_data}} -> {:ok, dependency_data}
    after
      time_out ->
        data = fun.(dependency)
        cond do
          is_data(data) -> {:ok, data}
          true -> recv_timout(dependency, fun, time_out, waiting_forever)
        end
    end
  end

  defp recv_timout(dependency, fun, time_out, waiting_forever) do
    if waiting_forever do
      recv(dependency, fun, time_out, waiting_forever)
    else
      {:timeout, fun.(dependency)}
    end
  end

  defp is_data(data) do
    not (is_nil(data) or data == false or (is_tuple(data) or is_map(data) or is_list(data) and Enum.empty?(data)))
  end

end
