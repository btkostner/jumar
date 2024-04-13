defmodule Jumar.MixProject do
  use Mix.Project

  @app :jumar
  @version "0.1.0"

  def project do
    [
      app: @app,
      name: "Jumar",
      description: "Jumar is a heavily opinionated Elixir boilerplate repository",
      version: @version,
      elixir: "~> 1.16",
      source_url: "https://github.com/btkostner/jumar",
      homepage_url: "https://jumar.btkostner.io",
      compilers: [:boundary] ++ Mix.compilers(),
      releases: [{@app, release()}],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [summary: [threshold: 0]],
      preferred_cli_env: elixir_envs(),
      aliases: aliases(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {JumarCli, []}
    ]
  end

  defp release do
    [
      overwrite: true,
      quiet: true,
      strip_beams: Mix.env() == :prod
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "benchmark/support", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specific default environments for non standard commands.
  defp elixir_envs() do
    [
      benchmark: :test
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:argon2_elixir, "~> 4.0"},
      {:bandit, "~> 1.3"},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:boundary, "~> 0.10"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.21", only: [:dev, :test]},
      {:ecto_sql, "~> 3.6"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false},
      {:finch, "~> 0.18"},
      {:floki, "~> 0.30", only: :test},
      {:gettext, "~> 0.20"},
      {:heroicons, "~> 0.5"},
      {:jason, "~> 1.2"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20"},
      {:phoenix, "~> 1.7"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:remote_ip, "~> 1.1"},
      {:sobelow, "~> 0.11", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 0.6", only: [:dev, :test]},
      {:swoosh, "~> 1.3"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:tailwind_formatter, "~> 0.3", only: :dev, runtime: false},
      {:telemetry, "~> 1.2"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      benchmark: [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "run benchmark/benchmark_helper.exs"
      ],
      docs: ["boundary.ex_doc_groups", "docs"],
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  # ExUnit documentation
  defp docs do
    [
      assets: "docs/assets",
      canonical: "https://jumar.btkostner.io",
      extras: extras(),
      formatters: ["html", "epub"],
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules(),
      logo: "docs/assets/logos/logomark.svg",
      main: "readme",
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      source_ref: "main"
    ]
  end

  defp extras do
    [
      "README.md",
      "CHANGELOG.md",
      "docs/database.md",
      "docs/deployment.md",
      "docs/development.md",
      "docs/documentation.md"
    ]
  end

  defp groups_for_extras do
    [
      Introduction: [
        "README.md",
        "CHANGELOG.md",
        "docs/development.md",
        "docs/deployment.md"
      ],
      Decisions: [
        "docs/database.md",
        "docs/documentation.md"
      ]
    ]
  end

  defp groups_for_modules do
    # We still want to compile the mix.exs file even if
    # the boundary.exs file is missing.
    if File.exists?("boundary.exs") do
      {list, _} = Code.eval_file("boundary.exs")
      list
    else
      []
    end
  end
end
