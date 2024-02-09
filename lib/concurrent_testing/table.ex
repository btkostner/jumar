defmodule ConcurrentTesting.Table do
  @moduledoc """
  A table linking concurrent testing references (`t:ConcurrentTesting.t`)
  to metadata (`t:ConcurrentTesting.metadata`).
  """

  use GenServer

  @table_name :concurrent_testing

  @doc """
  Starts the ConcurrentTesting table.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Grabs the current metadata for a reference. Returns `nil`
  if the reference does not exist.
  """
  @spec get(ConcurrentTesting.t()) :: ConcurrentTesting.metadata() | nil
  def get(reference) do
    GenServer.call(:get, reference)
  end

  @doc """
  Inserts a new row of reference and metadata to the table.
  """
  @spec insert(ConcurrentTesting.t(), ConcurrentTesting.metadata()) :: :ok
  def insert(reference, metadata \\ %{}) do
    GenServer.cast(__MODULE__, {:insert, reference, metadata})
  end

  @doc false
  @impl GenServer
  def init(_opts) do
    :ets.new(@table_name, [:protected, :named_table, read_concurrency: true])
    {:ok, nil}
  end

  @doc false
  @impl GenServer
  def handle_cast({:insert, reference, metadata}, state) do
    :ets.insert(@table_name, {reference, metadata})
    {:noreply, state}
  end

  @doc false
  @impl GenServer
  def handle_call(:get, reference, state) do
    if [{^reference, metadata}] = :ets.lookup(@table_name, reference) do
      {:reply, metadata, state}
    else
      {:reply, nil, state}
    end
  end
end
