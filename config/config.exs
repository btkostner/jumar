# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :jumar, :scopes,
  user: [
    default: true,
    module: Jumar.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :binary_id,
    schema_table: :users,
    test_data_fixture: Jumar.AccountsFixtures,
    test_setup_helper: :register_and_log_in_user
  ]

config :jumar, ecto_repos: [Jumar.Repo]

config :jumar, :generators,
  binary_id: true,
  migration_primary_key: [name: :uuid, type: :binary_id],
  migration_timestamps: [type: :utc_datetime],
  sample_binary_id: "00000000-0000-0000-0000-000000000000",
  timestamp_type: :utc_datetime

# Configure the Database for better Cockroach support
config :jumar, Jumar.Repo,
  after_connect: {Postgrex, :query!, ["SET SESSION application_name = \"Jumar\";", []]},
  migration_lock: false,
  start_apps_before_migration: [:ssl],
  telemetry_prefix: [:repo]

# Configures the endpoint
config :jumar, JumarWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  compress: false,
  live_view: [signing_salt: "jE9V3Gn4"],
  pubsub_server: Jumar.PubSub,
  render_errors: [
    formats: [html: JumarWeb.ErrorHTML, json: JumarWeb.ErrorJSON],
    layout: false
  ],
  url: [host: "localhost"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :jumar, Jumar.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  jumar: [
    args: ~w(
      assets/js/app.js
      --bundle
      --target=es2022
      --outdir=priv/static/assets/js
      --external:assets/fonts/*
      --external:assets/images/*
      --alias:@=.
    ),
    cd: Path.expand("..", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ],
  version: "0.25.4"

# Configure tailwind (the version is required)
config :tailwind,
  jumar: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ],
  version: "4.1.7"

# Configures Elixir's Logger
config :logger, handle_otp_reports: true

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
