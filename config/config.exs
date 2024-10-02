# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :jumar, ecto_repos: [Jumar.Repo]

config :jumar, :generators,
  binary_id: true,
  migration_timestamps: [type: :utc_datetime],
  sample_binary_id: "00000000-0000-0000-0000-000000000000"

# Configure the Database for better Cockroach support
config :jumar, Jumar.Repo,
  after_connect: {Postgrex, :query!, ["SET SESSION application_name = \"Jumar\";", []]},
  migration_lock: false,
  migration_primary_key: [name: :uuid, type: :binary_id],
  migration_timestamps: [type: :utc_datetime],
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
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
