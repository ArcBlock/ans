defmodule Ansc.MixProject do
  use Mix.Project

  def project do
    [
      app: :ansc,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :forge_sdk],
      mod: {Ansc.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mcc, "~> 1.2"},
      {:forge_core_protocols, git: "git@github.com:ArcBlock/forge-core-protocols.git"}
    ]
  end
end
