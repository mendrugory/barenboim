# Barenboim

# Conejo

[![hex.pm](https://img.shields.io/hexpm/v/barenboim.svg?style=flat-square)](https://hex.pm/packages/barenboim) [![hexdocs.pm](https://img.shields.io/badge/docs-latest-green.svg?style=flat-square)](https://hexdocs.pm/barenboim/) [![Build Status](https://travis-ci.org/mendrugory/barenboim.svg?branch=master)](https://travis-ci.org/mendrugory/barenboim)

 `Barenboim` is prepared to tackle with data streaming dependencies in concurrent flows.

  If your application works with a data streaming and your incoming events could have dependencies between them, the app can have problems about when the
  dependency data is ready. Reasons:
  * The Application which is sending the data is not sending the data in the right order
  * Your Application is treating the data concurrently therefore the order is not ensured.

## Installation
  * Add `barenboim` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
       [{:barenboim, "~> 0.1.0"}]
    end
    ```
    
## Configuration    
  * Barenboim uses [poolboy](https://github.com/devinus/poolboy) and you can configure it depending on your needs:

    ```elixir
    config :barenboim,
      pool_domain: :global,     # default :local
      pool_size: 20,            # default 10
      max_overflow: 3           # default 5
    ```

## How to use it
  Define the function that will retrieve the dependency data where `dependency_id` is the id of your data
  and call `Barenboim.get_data`. You can also specify a time out in milliseconds.
  ```elixir
  fun = fn(dependency_id) -> MyDataModule.get(dependency_id) end
  {:ok, data} = Barenboim.get_data(dependency_id, fun)
  ```

  Meanwhile, the flow that is processing a new event has to call `ready` function when the data is available for others.
  ```elixir
    Barenboim.ready(dependency_id)
  ```
  
## Test
  * Run the tests.
  ```bash
  mix test 
  ```
  
## In honor of
  [Daniel Barenboim](https://en.wikipedia.org/wiki/Daniel_Barenboim)
  
  