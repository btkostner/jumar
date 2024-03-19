defmodule Jumar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
  The Jumar application module. This starts all Jumar
  processes including the primary database connection,
  the PubSub system, and the Jumar web server. If you
  are just using Jumar as a library, you can instead
  include the `Jumar.Supervisor` module in your own
  supervisor tree.
  """

  use Application
  use Boundary, top_level?: true, deps: [Jumar, JumarWeb]

  @impl true
  def start(_type, _args) do
    children = [
      Jumar.Supervisor,
      JumarWeb.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JumarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
