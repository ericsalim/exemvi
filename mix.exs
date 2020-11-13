defmodule Exemvi.MixProject do
  use Mix.Project

  def project do
    [
      app: :exemvi,
      version: "0.1.0",
      elixir: "~> 1.11",
      name: "Exemvi",
      description: "A library that helps parsing and generating EMV QRCPS and QRIS",
      package: package()
    ]
  end

  def application do
    []
  end

  defp package do
    [
      %{
        licenses: ["Apache 2"],
        maintainers: ["Eric Salim"]
      }
    ]
  end
end
