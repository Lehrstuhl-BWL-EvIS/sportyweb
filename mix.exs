defmodule Sportyweb.MixProject do
  use Mix.Project

  def project do
    [
      app: :sportyweb,
      version: "0.4.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Docs configuration (via ExDoc)
      name: "Sportweb",
      source_url: "https://github.com/Lehrstuhl-BWL-EvIS/sportyweb",
      homepage_url: "https://github.com/Lehrstuhl-BWL-EvIS/sportyweb",
      docs: [
        extras: ["README.md", "CONTRIBUTING.md"],
        formatters: ["html"]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Sportyweb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      ###################################
      # Default Phoenix Dependencies

      # Don't use bcrypt_elixir!
      {:argon2_elixir, "~> 3.1"},
      {:phoenix, "~> 1.7.17"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},

      ###################################
      # Custom Dependencies

      # Date recurrence library based on iCalendar events
      # https://hexdocs.pm/cocktail/readme.html
      # https://github.com/peek-travel/cocktail
      {:cocktail, "~> 0.10"},

      # Linter for better code consistency
      # https://hexdocs.pm/credo/overview.html
      # https://github.com/rrrene/credo
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},

      # A mix task for generating Entity Relationship Diagrams
      # https://hexdocs.pm/ecto_erd/Mix.Tasks.Ecto.Gen.Erd.html
      # https://github.com/fuelen/ecto_erd
      {:ecto_erd, "~> 0.5", only: :dev},

      # Generates the documentation for the entire project
      # https://hexdocs.pm/ex_doc/readme.html
      # https://github.com/elixir-lang/ex_doc
      {:ex_doc, "~> 0.32", only: :dev, runtime: false},

      # Elixir implementation of Money with Currency
      # https://hexdocs.pm/ex_money/readme.html
      # https://github.com/kipcole9/money
      {:ex_money, "~> 5.15"},

      # Money functions for the serialization of a money data type
      # https://hexdocs.pm/ex_money_sql/readme.html
      # https://github.com/kipcole9/money_sql
      {:ex_money_sql, "~> 1.11"},

      # Generates fake data (primarily for the seed)
      # https://hexdocs.pm/faker/readme.html
      # https://github.com/elixirs/faker
      {:faker, "~> 0.18", only: [:dev, :test]},

      # Cron-like job scheduler for Elixir
      # https://hexdocs.pm/quantum/readme.html
      # https://github.com/quantum-elixir/quantum-core
      {:quantum, "~> 3.5"},

      # TimeZoneDatabase for DateTime (which per default only supports UTC)
      # https://hexdocs.pm/tzdata/readme.html
      # https://github.com/lau/tzdata
      {:tzdata, "~> 1.1"}
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
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind sportyweb", "esbuild sportyweb"],
      "assets.deploy": [
        "tailwind sportyweb --minify",
        "esbuild sportyweb --minify",
        "phx.digest"
      ]
    ]
  end
end
