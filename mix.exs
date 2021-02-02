defmodule Btc.MixProject do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))
  @github_url "https://github.com/clszzyh/btc"
  @description "Elixir bitcoin library"

  def project do
    [
      app: :btc,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [ci: :test],
      description: @description,
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_add_deps: :app_tree,
        plt_add_apps: [:ex_unit],
        list_unused_filters: true,
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: dialyzer_flags()
      ],
      docs: [
        source_ref: "v" <> @version,
        source_url: @github_url,
        main: "readme",
        extras: ["README.md", "CHANGELOG.md"]
      ],
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:prod), do: ~w(lib)
  defp elixirc_paths(_), do: ~w(lib test/support)

  # http://erlang.org/doc/man/dialyzer.html#gui-1
  defp dialyzer_flags do
    [
      :error_handling,
      :race_conditions,
      :underspecs,
      :unknown,
      :unmatched_returns
      # :overspecs
      # :specdiffs
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", runtime: false},
      {:bech32, ">= 0.0.0"},
      {:libsecp256k1, "~> 0.1.10"},
      {:b58, github: "dwyl/base58"}
    ]
  end

  defp aliases do
    [
      cloc: "cmd cloc --exclude-dir=_build,deps,doc .",
      ci: [
        "compile --warnings-as-errors --force --verbose",
        "format --check-formatted",
        "credo --strict",
        "docs",
        "dialyzer",
        "test"
      ]
    ]
  end
end
