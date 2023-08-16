defmodule Jumar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start our concurrent testing application first
      ConcurrentTesting.Application,
      # Start the Telemetry supervisor
      JumarWeb.Telemetry,
      # Start the Ecto repository
      Jumar.Repo,
      # Start the Ecto reconnecting process
      Jumar.RepoReconnector,
      # Start the PubSub system
      {Phoenix.PubSub, name: Jumar.PubSub},
      # Start Finch
      {Finch, name: Jumar.Finch},
      # Start the Endpoint (http/https)
      JumarWeb.Endpoint
      # Start a worker by calling: Jumar.Worker.start_link(arg)
      # {Jumar.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jumar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JumarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
