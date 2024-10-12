defmodule Jumar.Accounts.EventBusProducer do
  @moduledoc false

  use Jumar.EventBus.Producer

  alias Jumar.Accounts
  alias Jumar.EventBus

  @doc """
  Produces a new event based on the result of a `Jumar.Repo` operation. This
  can take the form of a transaction with a `user` key in the result map, or
  a simple `{:ok, user}` tuple. Everything else is ignored.
  """
  @spec produce_from_result(result, atom()) :: result
        when result: {:ok, %{user: Accounts.User.t()}} | {:ok, Accounts.User.t()} | any()
  def produce_from_result({:ok, %{user: %Accounts.User{} = user}} = result, event) do
    produce(event, user)
    result
  end

  def produce_from_result({:ok, %Accounts.User{} = user} = result, event) do
    produce(event, user)
    result
  end

  def produce_from_result(result, _event), do: result

  @doc """
  Produces a new event based on a user activity.
  """
  @spec produce(atom(), Accounts.User.t()) :: term()
  def produce(event, user) do
    EventBus.Producer.produce(__MODULE__, %EventBus.Event{
      name: event,
      data: user
    })
  end
end
