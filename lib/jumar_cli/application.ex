defmodule JumarCli.Server do
  @moduledoc """
  The default Jumar application module. This starts
  all of the sub processes like the web server,
  database connections, event processing, etc.
  Everything.

  It's written to be the default entry point for Jumar,
  and start up during testing.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Jumar.Supervisor,
      JumarWeb.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
