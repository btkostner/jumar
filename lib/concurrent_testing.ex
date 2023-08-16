defmodule ConcurrentTesting do
  @moduledoc """
  Concurrent Testing is a separate library that allows faster
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

  @reference_key "elixir-test"
  @process_key :elixir_test_reference

  @typedoc """
  A test reference. This is any valid given binary value that is
  stored in our reference table.
  """
  @type t :: binary()

  @typedoc """
  A map of all the stored metadata for a reference. This usually contains
  the current test pid, a database pool pid, Kafka consumer pid, etc.
  """
  @type metadata :: map()


  @doc """
  Retrieves the current reference for the process. This can be `nil` if
  not ran in a test.
  """
  @spec current_reference() :: t() | nil
  def current_reference() do
    Process.get(@process_key)
  end

  @doc """
  Looks at our internal reference metadata table and attempts to find
  the metadata for a given reference.
  """
  @spec get_metadata(t()) :: metadata() | nil
  def get_metadata(reference) do
    ConcurrentTesting.Table.get(reference)
  end

  @doc """
  Similar to the above function, but if the metadata table does not include
  the given reference, it's created.
  """
  @spec get_or_create_metadata(t(), map()) :: metadata()
  def get_or_create_metadata(reference, metadata \\ %{}) do
    case get_metadata(reference) do
      nil ->
        ConcurrentTesting.Table.insert(reference, metadata)
        metadata

      metadata ->
        metadata
    end
  end

  @doc """
  Extracts the current test reference from an enumerable. This is usually
  ran by consumers like Kafka consumers or HTTP servers.

  ## Examples

      iex> extract_reference([{"elixir-test", "test-reference}])
      "test-reference"

      iex> extract_reference(%{"elixir-test" => "another-test"})
      "another-test"

      iex> extract_reference([])
      nil

  """
  @spec extract_reference(Enum.t()) :: binary() | nil
  def extract_reference(enumerable) do
    Enum.find_value(enumerable, fn {key, value} ->
      if String.downcase(key) == @reference_key do
        value
      end
    end)
  end

  @doc """
  Inserts a given test reference into an enumerable. This is usually ran
  by producers like HTTP clients and Kafka producers to add the test
  reference to headers. For ease of use, if `nil` is passed in as a reference
  this function is a no-op.

  ## Examples

      iex> insert_reference([], "test-reference")
      [{"elixir-test", "test-reference}]

      iex> insert_reference(%{}, "another-test")
      %{"elixir-test" => "another-test"}

      iex> insert_reference(%{}, nil)
      %{}

  """
  @spec insert_reference(enumerable, t() | nil) :: enumerable
        when enumerable: list({binary(), binary()}) | %{required(binary()) => binary()}
  def insert_reference(enumerable, nil), do: enumerable

  def insert_reference(enumerable, reference) when is_map(enumerable),
    do: enumerable |> Enum.to_list() |> insert_reference(reference) |> Map.new()

  def insert_reference(enumerable, reference) do
    removed_existing_references =
      Enum.reject(enumerable, fn {key, _value} ->
        String.downcase(key) == @reference_key
      end)

    [{@reference_key, reference} | removed_existing_references]
  end

  @doc """
  Inserts the current test reference into an enumerable. If this function is
  ran when no current test reference exists, it's a no-op.
  """
  @spec insert_reference(enumerable) :: enumerable
        when enumerable: list({binary(), binary()}) | %{required(binary()) => binary()}
  def insert_reference(enumerable) do
    insert_reference(enumerable, current_reference())
  end
end
