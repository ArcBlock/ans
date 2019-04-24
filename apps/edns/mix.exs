defmodule Edns.MixProject do
  use Mix.Project

  def project do
    [
      app: :edns,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Edns.Application, []}
    ]
  end

  defp elixirc_paths(env) when env in [:test], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:dnsm, github: "exdns/dnsm"},
      {:jason, "~> 1.1"},
      {:mcc, "~> 1.2"},
      {:typed_struct, "~> 0.1.4"},
      {:poolboy, "~> 1.5"},
      #
      {:ansc, in_umbrella: true},
      # non-prod
      {:excoveralls, "~> 0.10.6", only: [:test]},
      {:mock, "~> 0.3.3", only: [:test]}
    ]
  end
end
