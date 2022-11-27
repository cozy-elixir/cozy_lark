defmodule CozyLark.MixProject do
  use Mix.Project

  @version "0.2.0"
  @description "An SDK builder of Lark Open Platform / Feishu Open Platform."
  @source_url "https://github.com/cozy-elixir/cozy_lark"

  def project do
    [
      app: :cozy_lark,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      package: package(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {CozyLark.Application, []},
      env: [json_library: Jason, server_side_api_client: CozyLark.ServerSideAPI.Client.Finch]
    ]
  end

  defp deps do
    [
      {:con_cache, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:finch, "~> 0.13", only: [:dev, :test]},
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
