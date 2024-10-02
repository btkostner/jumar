defmodule Jumar.Audit.EventBusConsumer do
  @moduledoc false

  use Jumar.EventBus.Consumer,
    producers: [
      {Jumar.Accounts.EventBusProducer, max_demand: 100}
    ]

  require Logger

  @doc false
  @impl Jumar.EventBus.Consumer
  def handle_event(_event) do
    :ok
  end

  @doc false
  @impl Jumar.EventBus.Consumer
  def handle_failure(event, error) do
    Logger.error("Failed to create audit record of event", event: event, error: inspect(error))
  end
end
