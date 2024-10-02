defmodule Jumar.EventBus.Producer do
  @moduledoc """
  A GenStage implementation to produce events.

  ## Usage

      defmodule MyProducer do
        use Jumar.EventBus.Producer
      end

  Then you can use the producer module to produce events like so:

      iex> MyProducer.produce(%Jumar.EventBus.Event{})

  In many cases, you may want to customize the produce function and
  make it easier to use around you context. To do this, you can create
  a wrapper function that calls `MyProducer.produce/1` with the event
  data.

      defmodule MyProducer do
        use Jumar.EventBus.Producer

        def produce(event, %User{} = user) do
          MyProducer.produce(%Jumar.EventBus.Event{
            event: event,
            data: %{
              user: user
            }
          })
        end
      end

  And then call your `produce/2` function like so:

        iex> MyProducer.produce(:user_created, %User{id: 1})
  """

  alias Jumar.EventBus

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @doc false
      def child_spec(args) do
        default = %{
          id: __MODULE__,
          start: {Jumar.EventBus.Producer, :start_link, [args, [name: __MODULE__]]}
        }

        Supervisor.child_spec(default, unquote(Macro.escape(opts)))
      end
    end
  end

  use GenStage

  alias Jumar.EventBus

  @typep demand :: non_neg_integer()
  @typep state :: {:queue.queue(), integer()}

  @doc """
  Starts the producer.
  """
  def start_link(args, opts \\ []) do
    GenStage.start_link(__MODULE__, args, opts)
  end

  @doc """
  Produces an event to the event dispatcher. Will return `:ok` once the event has
  been dispatched or placed in queue waiting to be dispatched.
  """
  @spec produce(module(), EventBus.Event.t()) :: term()
  def produce(mod, event) do
    GenStage.call(mod, {:notify, event}, 5000)
  end

  @doc false
  def init(_args) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  @doc false
  @spec handle_call({:notify, EventBus.Event.t()}, {pid(), reference()}, state()) ::
          {:noreply, [EventBus.Event.t()], state()}
  def handle_call({:notify, event}, from, {queue, pending_demand}) do
    queue = :queue.in({from, event}, queue)
    dispatch_events(queue, pending_demand, [])
  end

  @doc false
  @spec handle_demand(integer(), state()) :: {:noreply, [EventBus.Event.t()], state()}
  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  @spec dispatch_events(:queue.queue(), demand(), [EventBus.Event.t()]) ::
          {:noreply, [EventBus.Event.t()], state()}
  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  @spec dispatch_events(:queue.queue(), demand(), [EventBus.Event.t()]) ::
          {:noreply, [EventBus.Event.t()], state()}
  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, {from, event}}, queue} ->
        GenStage.reply(from, :ok)
        dispatch_events(queue, demand - 1, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
