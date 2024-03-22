defmodule JumarCli do
  @moduledoc """
  The JumarCli module contains custom commands
  that are used by `mix release` and the generated
  Docker file. This allows us to have Elixir code for
  running migrations, rollbacks, database seeds, web
  servers, etc.
  """

  use Application

  use Boundary,
    deps: [Jumar, JumarWeb],
    exports: []

  @impl true
  def start(type, args) do
    case System.get_env("JUMAR_CMD") do
      "migrate" -> JumarCli.Migrate.start(type, args)
      "rollback" -> JumarCli.Migrate.start(type, args)
      "server" -> JumarCli.Migrate.start(type, args)
      _ -> {:ok, self()}
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JumarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
