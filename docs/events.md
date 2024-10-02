# Events

Events can be broken down into three different categories. Each category has a specific use case and different messaging garantees, so be mindful when picking.

## PubSub

First up, you have your PubSub events. Internally this is done with Phoenix PubSub and it's a great way to broadcast messages to web clients. This is designed for consumers who connect and disconnect very frequently and where events need to be handled across nodes. If a client is disconnected when a message is broadcasted, it will not be delivered.

## Event Bus

The event bus is a way to deal with cross context information. These are high throughput messages processed completely in memory, and therefor have no garantee of processing aside from what the BEAM can provide. This means messages will be handled unless a major software or hardware failure occures.

To summarize, think of these two pieces of psudo code as the same, but one is much easier to maintain and extend.

```elixir
# This code requires you to update code from seperate contexts, making
# it harder to maintain, extend, or remove.
defmodule Accounts do
  def create_user(attrs) do
    with {:ok, user} <- User.create(attrs) do
      Task.async(fn -> Audit.on_user_create(user) end)
      Task.async(fn -> Search.on_user_create(user) end)
      {:ok, user}
    end
  end
end

defmodule Audit do
  def on_user_create(user) do
    # Do something with the newly created user
  end
end

defmodule Search do
  def on_user_create(user) do
    # Update our search index
  end
end
```

```elixir
# This code on the other hand is much easier to maintain and extend.
# If you need to create a new context, you can add a new consumer without
# touching the existing code.
defmodule Accounts do
  def create_user(attrs) do
    with {:ok, user} <- User.create(attrs) do
      :ok = EventBus.emit(:user_created, user)
      {:ok, user}
    end
  end
end

defmodule Audit do
  def process_event(:user_created, user) do
    # Do something with the newly created user
  end
end

defmodule Search do
  def process_event(:user_created, user) do
    # Update our search index
  end
end
```

The event bus **does not provide retry or replay functionality**. It is purely a better way to decouple contexts. If you find yourself needing more garantees, retries, or are using third party services that has a finiky API, you (as the consumer) will need to handle that yourself. This is to prevent the event bus from becoming a catch all for every type of event, as well as adding complexity to the system.

## Worker Queue

The worker queue has the most garantees and is best suited for long tasks that can be done asynchronously and might need to be retried or replayed at a later date. This is currently done with Broadway and RabbitMQ but can be switched out to Oban or a number of other hosted queue systems. This is a great way to offload work from the main application and keep things running smoothly.

## What to use and when

Here is a quick non exaustive list of questions to help you decide on when to use each:

- Do you need to broadcast a message to clients? Use PubSub.
- Do you know what the consumer code will look like? Use a worker queue.
- Do you want to clean up a bunch of unrelated cross context code? Use the event bus.
- Is there a possibility of the message failing and someone asking for it to be reprocessed? Use a worker queue.
- Is there a possibility of using another language to consume the message? Use a worker queue.
- Are you subscribing from a LiveView or websocket? Use PubSub.
