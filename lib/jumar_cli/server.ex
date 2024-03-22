defmodule JumarCli.Application do
  @moduledoc """
  The default Jumar application module. This starts
  all of the sub processes like the web server,
  database connections, event processing, etc.
  Everything.
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
