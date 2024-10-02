defmodule Jumar.Audit.AccountEventBusConsumer do
  @moduledoc false

  use Jumar.EventBus.Consumer,
    producers: [
      {Jumar.Accounts.EventBusProducer, max_demand: 100}
    ]

  @doc false
  @impl Jumar.EventBus.Consumer
  def handle_event(_event) do
    :ok
  end
end
