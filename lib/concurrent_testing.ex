defmodule ConcurrentTesting do
  @moduledoc """
  Concurrent Testing is a seperate library that allows faster
  and more isolated tests in a large distributed environment.

  ## Why

  Let's think about a small system first. We have a single application
  that wants to run tests concurrently. When this happens without any
  prior setup, you run into issues where the database will have data
  from other tests. This is a huge pain and delt with a couple of
  different ways:

  1) You simply don't run tests concurrently. This works but it's slow.

  2) Ensure your data never overlaps. This takes a very large time
  for a developer to do correctly, and still leads to edge cases where
  queries not filtered correctly can leak data.

  3) Run everything in a transaction. This is what most libraries as
  it uses your database's transaction guarantees to ensure data is not
  leaked between tests.

  Phoenix supports number 3 via the `Phoenix.Ecto.SQL.Sandbox` module.
  This works _great_ but has a couple of downsides in large distributed
  systems.

  ## Problems

  1) It only wraps the database, so RabbitMQ messages are still consumed
  outside of the transaction

  2) You have to call an endpoint to create a transaction. This means
  cascading calls with every service which takes a while.

  ## Differences

  To solve these problems, we've recreated the `Phoenix.Ecto.SQL.Sandbox`
  module using a registry pattern, and generalized it to be useful in
  other transports like HTTP or RabbitMQ.

  Firstly, we use a registry to store arbitrary keys instead of encoding
  the pid data. This allows us to use the same key for all services in
  the same distributed test.

  Secondly, we expose easy to use functions for producing and consuming
  libraries to use. This makes it easy to integrate no matter what data
  source you are using.

  Lastly, we don't require a request to create the initial transaction.
  If the given key is unknown, we will create a new transaction on the
  fly. Then after the configured timeout, the transaction automatically
  closes. This prevents cascading transaction create calls in a distributed
  system.
  """
end
