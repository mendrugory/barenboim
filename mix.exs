defmodule Barenboim.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [app: :barenboim,
     version: @version,
     elixir: "~> 1.4",
     package: package(),
     description: "Barenboim helps you with data streaming dependencies in concurrent flows",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     docs: [main: "Barenboim", source_ref: "v#{@version}",
     source_url: "https://github.com/mendrugory/barenboim"]]
  end


  def application do
    [extra_applications: [:logger],
     mod: {Barenboim.Application, []}]
  end

  defp deps do
    [{:poolboy, "~> 1.5"},
    {:earmark, ">= 0.0.0", only: :dev},
    {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    %{licenses: ["MIT"],
      maintainers: ["Gonzalo Jiménez Fuentes"],
      links: %{"GitHub" => "https://github.com/mendrugory/barenboim"}}
  end
end
