defmodule Jumar.Types.PrefixedUUID do
  @moduledoc """
  A custom `Ecto.ParameterizedType` that prefixes an `Ecto.UUID` on the
  application side to have something similar to how Stripe does
  `usr_abc123` for their keys.
  """

  use Ecto.ParameterizedType

  alias Ecto.UUID

  @typedoc """
  A binary value of the prefixed UUID
  """
  @type t :: binary()

  @typedoc """
  The parameters for a prefixed UUID. This only includes the binary prefix
  itself.
  """
  @type params :: %{required(:prefix) => binary()}

  @doc """
  Returns the underlying schema type for a prefixed uuid. This is a basic UUID
  under the hood and is stored the same way an `Ecto.UUID` would be.
  """
  def type(_params), do: UUID.type()

  @doc """
  Converts the given options to `t:params`. Raises if the prefix is missing or
  not binary.
  """
  @spec init(Ecto.ParameterizedType.opts()) :: params()
  def init(opts) do
    unless Keyword.has_key?(opts, :prefix) do
      raise ArgumentError, message: "#{__MODULE__} was not given a prefix."
    end

    unless opts |> Keyword.get(:prefix) |> is_binary() do
      raise ArgumentError, message: "#{__MODULE__} was given an invalid prefix."
    end

    Enum.into(opts, %{})
  end

  @doc """
  Casts a given input to a prefixed UUID.
  """
  @spec cast(term(), params()) :: {:ok, t()} | :error
  def cast(possible_uuid, %{prefix: prefix}) when is_binary(possible_uuid) do
    case possible_uuid |> String.trim_leading(prefix <> "_") |> UUID.dump() do
      {:ok, binary_uuid} -> {:ok, prefix <> binary_uuid}
      :error -> :error
    end
  end

  def cast(_data, _params), do: :error

  @doc """
  Loads data from the database to a prefixed UUID.
  """
  @spec load(any(), function(), params()) :: {:ok, any()} | :error
  def load(binary_uuid, _loader, %{prefix: prefix}) when is_binary(binary_uuid) do
    case UUID.load(binary_uuid) do
      {:ok, binary_uuid} -> {:ok, prefix <> binary_uuid}
      :error -> :error
    end
  end

  def load(_data, _loader, _params), do: :error

  @doc """
  Dumps the given prefixed UUID to an Ecto native type.
  """
  @spec dump(any(), function(), params()) :: {:ok, any()} | :error
  def dump(data, _dumper, %{prefix: prefix}) when is_binary(data) do
    case data |> String.trim_leading(prefix <> "_") |> UUID.dump() do
      {:ok, raw_uuid} -> {:ok, raw_uuid}
      :error -> :error
    end
  end

  def dump(_data, _dumper, _params), do: :error

  @doc """
  Checks if the two prefixed UUIDs are equal. This is a basic `==` equality
  checker.
  """
  @spec equal?(any(), any(), params()) :: boolean()
  def equal?(a, b, _params), do: a == b

  @doc """
  Generates a new prefixed UUID.
  """
  def generate(%{prefix: prefix}), do: prefix <> "_" <> UUID.generate()
end
