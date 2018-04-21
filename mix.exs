defmodule CoxirCommander.MixProject do
  use Mix.Project

  def project do
    [
      app: :coxir_commander,
      version: "0.1.0",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,

      name: "coxir_commander",
      package: package(),
      description: "A command handler utility for coxir.",
      source_url: "https://github.com/satom99/coxir_commander"
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      maintainers: ["Santiago Tortosa"],
      links: %{"GitHub" => "https://github.com/satom99/coxir_commander"}
    ]
  end
end
