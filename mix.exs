defmodule Exemvi.MixProject do
  use Mix.Project

  def project do
    [
      app: :exemvi,
      version: "0.1.2",
      elixir: "~> 1.11",
      name: "Exemvi",
      description: description(),
      package: package(),
      source_url: "https://github.com/ericsalim/exemvi",
      deps: deps(),
      docs: [
        extras: ["README.md"],
        main: "readme"
      ]
    ]
  end

  def application do
    []
  end

  defp description() do
    "A library to work with EMV QR Code Specification for Payment Systems"
  end

  defp package do
    [
      name: "exemvi",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["Apache-2.0"],
      maintainers: ["Eric Salim"],
      links: %{"GitHub" => "https://github.com/ericsalim/exemvi"}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
