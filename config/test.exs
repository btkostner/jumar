import Config

ci? = System.get_env("CI", "") != ""

# Only in tests, remove the complexity from the password hashing algorithm
config :argon2_elixir, t_cost: 1, m_cost: 8

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :jumar, Jumar.Repo,
  username: "root",
  hostname: "localhost",
  port: 26_257,
  database: "jumar_test#{System.get_env("MIX_TEST_PARTITION")}",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jumar, JumarWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4_002],
  secret_key_base: "tx51cQwxmBejOFl/mlhhzbqjPn4rd1HA6KZs0IxcV+YJIiQW1Knglg+6YwTaaO1J",
  server: false

# In test we don't send emails.
config :jumar, Jumar.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :stream_data,
  max_runs: if(ci?, do: 10_000, else: 1_000)
