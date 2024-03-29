defmodule JumarCli.Application do
  @moduledoc """
  Starts the phoenix web server.
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
