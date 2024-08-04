defmodule JumarCli.Server do
  @moduledoc """
  Usage: jumar server

  Starts the Jumar web server.
  """
  @shortdoc "Starts the Jumar web server"

  use JumarCli.Command

  @impl JumarCli.Command
  def run(_command_line_args) do
    children = [
      Jumar.Supervisor,
      JumarWeb.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
