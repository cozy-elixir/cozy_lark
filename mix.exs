defmodule CozyLark.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/cozy-elixir/cozy_lark"
  @description "Elixir SDK of Lark Open Platform."

  def project do
    [
      app: :cozy_lark,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # doc
      description: @description,
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      # package
      package: package(),
      # aliases
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {CozyLark.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, ">= 1.0.0"},
      {:finch, "~> 0.13"},
      {:con_cache, "~> 1.0"},
      {:ex_doc, "~> 0.25", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: @version
    ]
  end

  defp package do
    [
      exclude_patterns: [],
      licenses: ["Apache-2.0"],
      links: %{GitHub: @source_url}
    ]
  end

  defp aliases do
    [publish: ["hex.publish", "tag"], tag: &tag_release/1]
  end

  defp tag_release(_) do
    Mix.shell().info("Tagging release as #{@version}")
    System.cmd("git", ["tag", @version])
    System.cmd("git", ["push", "--tags"])
  end
end
