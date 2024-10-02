defmodule Jumar.PubSub do
  @moduledoc """
  A `Phoenix.PubSub` implementation for dispatching messages
  to ephemeral processes.

  For more information on the Jumar event system, see the
  [events documentation](/events.html).
  """

  @doc false
  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts) do
    Supervisor.child_spec(
      {Phoenix.PubSub.Supervisor,
       [
         adapter: Phoenix.PubSub.PG2,
         name: __MODULE__
       ]},
      opts
    )
  end
end
