defmodule JumarNotification.Supervisor do
  @moduledoc false

  use Supervisor

  @doc false
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc false
  @impl Supervisor
  def init(_args) do
    children = [
      # Start any processes used for notification communication
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.init(children, strategy: :one_for_one)
  end
end
