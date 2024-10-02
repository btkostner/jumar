defmodule Jumar.EventBus.Consumer do
  @moduledoc """
  A GenStage ConsumerSupervisor implementation to consume events
  from `Jumar.EventBus.Producer`.

  ## Usage

      defmodule MyConsumer do
        use Jumar.EventBus.Consumer,
          producers: [MyProducer]

        def handle_event(event) do
          IO.inspect(event)
        end
      end

  You can also specify multiple producers to subscribe to, as well as all other
  options available in `ConsumerSupervisor`.

      defmodule MyConsumer do
        use Jumar.EventBus.Consumer,
          producers: [
            {MyProducer, min_demand: 1, max_demand: 50},
            {AnotherProducer, max_demand: 200}
          ]

        def handle_event(event) do
          IO.inspect(event)
        end
      end

  See the `ConsumerSupervisor` module documentation on producers for more options.
  """

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour Jumar.EventBus.Consumer

      @doc false
      def child_spec(args) do
        {producers, opts} = Keyword.pop(unquote(Macro.escape(opts)), :producers, [])

        args =
          args
          |> Keyword.put(:producers, producers)
          |> Keyword.put(:module, __MODULE__)

        default = %{
          id: __MODULE__,
          start: {Jumar.EventBus.Consumer, :start_link, [args, [name: __MODULE__]]}
        }

        Supervisor.child_spec(default, opts)
      end

      @doc false
      @impl Jumar.EventBus.Consumer
      def handle_failure(event, error), do: :ok

      defoverridable handle_failure: 2
    end
  end

  alias Jumar.EventBus

  @doc """
  Starts the consumer.
  """
  def start_link(args, opts \\ []) do
    ConsumerSupervisor.start_link(__MODULE__, args, opts)
  end

  @doc false
  @spec start_task_link(module(), EventBus.Event.t()) :: {:ok, pid()}
  def start_task_link(mod, event) do
    Task.start_link(fn ->
      do_task(mod, event)
    end)
  end

  @spec do_task(module(), EventBus.Event.t()) :: any()
  defp do_task(mod, event) do
    case mod.handle_event(event) do
      :ok -> :ok
      error -> mod.handle_failure(event, error)
    end
  rescue
    error -> mod.handle_failure(event, error)
  catch
    error -> mod.handle_failure(event, error)
  end

  @doc false
  def init(args) do
    mod = Keyword.fetch!(args, :module)
    producers = Keyword.fetch!(args, :producers)

    ConsumerSupervisor.init(
      [
        %{
          id: mod,
          start: {__MODULE__, :start_task_link, [mod]},
          restart: :transient
        }
      ],
      strategy: :one_for_one,
      subscribe_to: producers
    )
  end

  @callback handle_event(EventBus.Event.t()) :: :ok

  @callback handle_failure(EventBus.Event.t(), error: any()) :: :ok
end
