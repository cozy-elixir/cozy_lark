defmodule CozyLark.MixProject do
  use Mix.Project

  def project do
    [
      app: :cozy_lark,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:jason, ">= 1.0.0"}
    ]
  end
end
