defmodule Jumar.EventBus.Supervisor do
  @moduledoc false

  use Supervisor

  @consumers [
    Jumar.Audit.EventBusConsumer
  ]

  @producers [
    Jumar.Accounts.EventBusProducer
  ]

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Supervisor
  def init(_args) do
    Supervisor.init(@producers ++ @consumers, strategy: :one_for_one)
  end
end
