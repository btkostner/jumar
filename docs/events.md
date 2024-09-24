# Events

Events can be broken down into three different categories. Each category has a specific use case and different messaging garantees, so be mindful when picking.

## PubSub

First up, you have your PubSub events. Internally this is done with Phoenix PubSub and it's a great way to broadcast messages to clients. These messages have **zero garantee of delivery** and are purely informational.

## Event Bus

The event bus is a way to deal with cross context information. These are high throughput messages that have a **best effort garantee of delivery and minimal persistence**.

This is made possible with an adapter pattern module that uses `gen_stage` by default for fast handling and easy infrastructure. This is the simplest adapter and runs completely in memory in each node. In situations where you want more guarentees, like persistence during deploys, you can swap this out for a RabbitMQ adapter.

The best way to explain this is with some examples. Say you have some business contexts like a user context and post context that each emit their own events. Later down the line it's determined you want to create an audit log. This new audit context can now simply listen to the events emitted by the user and post contexts and insert a new row into the database. This decouples the two contexts making everything easier to read and understand. However, you can get yourself into trouble overusing this pattern. Be mindful of what you are emitting, avoid circular events, and remember that this is a way to decouple logic. If you find yourself needing to emit an event to trigger another event, you're probably doing it wrong.

## Worker Queue

The worker queue has the most garantees and is best suited for long tasks that can be done asynchronously and might need to be retried or replayed at a later date. This is currently done with Broadway and RabbitMQ but can be switched out to Oban or a number of other hosted queue systems. This is a great way to offload work from the main application and keep things running smoothly.

## What to use and when

Here is a quick non exaustive list of questions to help you decide on when to use each:

- Do you need to broadcast a message to clients? Use PubSub.
- Do you know what the consumer code will look like yet? Use a worker queue.
- Do you want to clean up a bunch of unrelated cross context code? Use the event bus.
- Is there a possibility of the message failing and someone asking for it to be reprocessed? Use a worker queue.
- Is there a possibility of using another language to consume the message? Use a worker queue.
- Are you subscribing from a LiveView or websocket? Use PubSub.
