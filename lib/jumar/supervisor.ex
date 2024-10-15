defmodule Jumar.Supervisor do
  @moduledoc """
  The Jumar application supervisor that starts all required
  dependencies of the main Jumar application. This is separate
  from the `Jumar.Application` module to allow for easier use
  in third party projects, without also including web server
  processes.
  """

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Supervisor
  def init(_args) do
    children = [
      # Start the Ecto repository
      Jumar.Repo,
      # Start the Ecto reconnecting process
      Jumar.Repo.Reconnector,
      # Start the PubSub system
      Jumar.PubSub,
      # Start the Event Bus system
      Jumar.EventBus.Supervisor,
      # Start Finch
      {Finch, name: Jumar.Finch}
      # Start a worker by calling: Jumar.Worker.start_link(arg)
      # {Jumar.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.init(children, strategy: :one_for_one)
  end
end
