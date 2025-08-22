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
      elixir: "~> 1.18",
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
      applications: [runtime_tools: :permanent],
      include_executables_for: [:unix],
      overwrite: true,
      quiet: true,
      strip_beams: strip_beams(Mix.env())
    ]
  end

  defp strip_beams(:prod), do: [keep: ["Docs", "Dbgi"]]
  defp strip_beams(_), do: false

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "benchmark/support", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specific default environments for non standard commands.
  defp elixir_envs do
    [
      benchmark: :test
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:argon2_elixir, "~> 4.1"},
      {:bandit, "~> 1.6"},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:boundary, "~> 0.10"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.22", only: [:dev, :test]},
      {:ecto_sql, "~> 3.12"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      {:finch, "~> 0.19"},
      {:floki, "~> 0.37", only: :test},
      {:gen_stage, "~> 1.2"},
      {:gettext, "~> 0.26"},
      {:heroicons, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:opentelemetry_semantic_conventions, "~> 1.27"},
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:remote_ip, "~> 1.2"},
      {:sobelow, "~> 0.14", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.1", only: [:dev, :test]},
      {:swoosh, "~> 1.18"},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:tailwind_formatter, "~> 0.4", only: :dev, runtime: false},
      {:telemetry, "~> 1.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"}
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
      "docs/documentation.md",
      "docs/events.md"
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
        "docs/documentation.md",
        "docs/events.md"
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
