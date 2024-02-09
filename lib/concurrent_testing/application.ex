defmodule ConcurrentTesting.Application do
  @moduledoc """
  Entry point for concurrent testing processes.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc false
  @impl Supervisor
  def init(_opts) do
    children = [
      ConcurrentTesting.Table
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
