defmodule JumarWeb.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      # Start the Telemetry supervisor
      JumarWeb.Telemetry,
      # Start the Endpoint (http/https)
      JumarWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.init(children, strategy: :one_for_one)
  end
end
