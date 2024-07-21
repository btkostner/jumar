defmodule JumarCli.Application do
  @moduledoc """
  Starts the everything in Jumar. This includes the
  database, web server, background processing, and more.
  """
  @shortdoc "Starts the everything in Jumar"

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
