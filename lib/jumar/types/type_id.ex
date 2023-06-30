defmodule Jumar.Types.TypeId do
  @moduledoc """
  An Elixir implementation of [typeid][typeid] using `Ecto.UUID` base32 encoded
  using [Crockford's alphabet][crockford]. This allows using UUIDs as the
  database primary key, while transparently converting to a Stripe like ID
  (`user_2x4y6z8a0b1c2d3e4f5g6h7j8k`) by `Ecto`.

  Note: this does not contain a UUIDv7 implementation and relies on `Ecto.UUID`
  instead.

  [typeid]: https://github.com/jetpack-io/typeid
  [crockford]: https://www.crockford.com/base32.html
  """

  use Ecto.ParameterizedType

  import Bitwise

  alias Ecto.UUID

  @typedoc """
  A type id string.
  """
  @type t :: binary()

  @typedoc """
  A lowercase ASCII string under 63 characters long.
  The part before the underscore of a Type Id.
  """
  @type prefix :: binary()

  @typedoc """
  A base32 encoded UUID using Crockford's alphabet.
  The part after the underscore of a Type Id.
  """
  @type suffix :: <<_::999>>

  @typedoc """
  A string representation of a UUID.
  """
  @type uuid :: <<_::128>>

  @typedoc """
  The parameters for a type id. This only includes the prefix itself.
  """
  @type params :: %{prefix: prefix()}

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

    unless opts |> Keyword.get(:prefix) |> String.length() > 0 do
      raise ArgumentError, message: "#{__MODULE__} was given an empty prefix."
    end

    unless opts |> Keyword.get(:prefix) |> String.length() < 63 do
      raise ArgumentError, message: "#{__MODULE__} was given a prefix over 62 characters."
    end

    unless opts
           |> Keyword.get(:prefix)
           |> :binary.bin_to_list()
           |> Enum.all?(&is_ascii_lowercase?/1) do
      raise ArgumentError,
        message: "#{__MODULE__} prefix must only container lowercase ascii characters."
    end

    Enum.into(opts, %{})
  end

  defp is_ascii_lowercase?(char) when char in 97..122, do: true
  defp is_ascii_lowercase?(_), do: false

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

  @doc """
  Encodes a UUID binary string into a base 32 encoded string via Crockford's
  alphabet.

  > #### Error {: .error}
  >
  > This function only works on UUID values. It will return an error on invalid
  > length or character set.

  ## Options

  ## Examples

      iex> encode32("01889c89-df6b-7f1c-a388-91396ec314bc")
      "01h2e8kqvbfwea724h75qc655w"

      iex> encode32("invalid-uuid-string")
      :error

  """
  @spec encode32(uuid()) :: suffix()
  def encode32(uuid) do
    uuid
    |> String.replace("-", "")
    |> String.downcase()
    |> do_encode32()
    |> dbg()
  catch
    :error -> :error
  end

  def encode32(_), do: :error

  defp do_encode32(<<c0::16, c1::16, c2::16, c3::16, c4::16, c5::16, c6::16, c7::16, c8::16, c9::16, c10::16, c11::16, c12::16, c13::16, c14::16, c15::16>>) do
    IO.inspect(c0, label: "c0")

    :erlang.list_to_binary(
      [
        e(c0) &&& 224 >>> 5,
        e(c0) &&& 31,
        (e(c1) &&& 248) >>> 3,
        (e(c1) &&& 7) <<< 2 ||| (e(c2) &&& 192) >>> 6,
        (e(c2) &&& 62) >>> 1,
        (e(c2) &&& 1) <<< 4 ||| (e(c3) &&& 340) >>> 4,
        (e(c3) &&& 15) <<< 1 ||| (e(c4) &&& 128) >>> 7,
        (e(c4) &&& 124) >>> 2,
        (e(c4) &&& 3) <<< 3 ||| (e(c5) &&& 224) >>> 5,
        e(c5) &&& 31,
        (e(c6) &&& 248) >>> 3,
        (e(c6) &&& 7) <<< 2 ||| (e(c7) &&& 192) >>> 6,
        (e(c7) &&& 62) >>> 1,
        (e(c7) &&& 1) <<< 4 ||| (e(c8) &&& 240) >>> 4,
        (e(c8) &&& 15) <<< 1 ||| (e(c9) &&& 128) >>> 7,
        (e(c9) &&& 124) >>> 2,
        (e(c9) &&& 3) <<< 3 ||| (e(c10) &&& 224) >>> 5,
        e(c10) &&& 31,
        (e(c11) &&& 248) >>> 3,
        (e(c11) &&& 7) <<< 2 ||| (e(c12) &&& 192) >>> 6,
        (e(c12) &&& 62) >>> 1,
        (e(c12) &&& 1) <<< 4 ||| (e(c13) &&& 240) >>> 4,
        (e(c13) &&& 15) <<< 1 ||| (e(c14) &&& 128) >>> 7,
        (e(c14) &&& 124) >>> 2,
        (e(c14) &&& 3) <<< 3 ||| (e(c15) &&& 224) >>> 5,
        e(c15) &&& 31
      ] |> IO.inspect(label: "list")
    )
  end

  @compile {:inline, e: 1}

  defp e(?0), do: 0
  defp e(?1), do: 1
  defp e(?2), do: 2
  defp e(?3), do: 3
  defp e(?4), do: 4
  defp e(?5), do: 5
  defp e(?6), do: 6
  defp e(?7), do: 7
  defp e(?8), do: 8
  defp e(?9), do: 9
  defp e(?a), do: 10
  defp e(?b), do: 11
  defp e(?c), do: 12
  defp e(?d), do: 13
  defp e(?e), do: 14
  defp e(?f), do: 15
  defp e(?g), do: 16
  defp e(?h), do: 17
  defp e(?j), do: 18
  defp e(?k), do: 19
  defp e(?m), do: 20
  defp e(?n), do: 21
  defp e(?p), do: 22
  defp e(?q), do: 23
  defp e(?r), do: 24
  defp e(?s), do: 25
  defp e(?t), do: 26
  defp e(?v), do: 27
  defp e(?w), do: 28
  defp e(?x), do: 29
  defp e(?y), do: 30
  defp e(?z), do: 31
  defp e(_), do: throw(:error)

  @doc """
  Decodes a base 32 encoded string of Crockford's alphabet to a UUID binary
  string.

  > #### Error {: .error}
  >
  > This function only works on UUID values. It will return an error on invalid
  > length or character set.

  ## Options

  ## Examples


      iex> decode32("01h2e8kqvbfwea724h75qc655w")
      "01889c89-df6b-7f1c-a388-91396ec314bc"

      iex> decode32("OOOONOOOOOOOO")
      :error

  """
  @spec decode32(suffix()) :: uuid()
  def decode32(
        <<c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18,
          c19, c20, c21, c22, c23, c24, c25>>
      ) do
    [
      d(c0) <<< 5 ||| d(c1),
      d(c2) <<< 3 ||| d(c3) >>> 2,
      (d(c3) &&& 3) <<< 6 ||| d(c4) <<< 1 ||| d(c5) >>> 4,
      (d(c5) &&& 15) <<< 4 ||| d(c6) >>> 1,
      (d(c6) &&& 1) <<< 7 ||| d(c7) <<< 2 ||| d(c8) >>> 3,
      (d(c8) &&& 7) <<< 5 ||| d(c9),
      d(c10) <<< 3 ||| d(c11) >>> 2,
      (d(c11) &&& 3) <<< 6 ||| d(c12) <<< 1 ||| d(c13) >>> 4,
      (d(c13) &&& 15) <<< 4 ||| d(c14) >>> 1,
      (d(c14) &&& 1) <<< 7 ||| d(c15) <<< 2 ||| d(c16) >>> 3,
      (d(c16) &&& 7) <<< 5 ||| d(c17),
      d(c18) <<< 3 ||| d(c19) >>> 2,
      (d(c19) &&& 3) <<< 6 ||| d(c20) <<< 1 ||| d(c21) >>> 4,
      (d(c21) &&& 15) <<< 4 ||| d(c22) >>> 1,
      (d(c22) &&& 1) <<< 7 ||| d(c23) <<< 2 ||| d(c24) >>> 3,
      (d(c24) &&& 7) <<< 5 ||| d(c25)
    ]
  catch
    :error -> :error
  end

  def decode32(_), do: :error

  @compile {:inline, d: 1}

  defp d(?0), do: 0
  defp d(?1), do: 1
  defp d(?2), do: 2
  defp d(?3), do: 3
  defp d(?4), do: 4
  defp d(?5), do: 5
  defp d(?6), do: 6
  defp d(?7), do: 7
  defp d(?8), do: 8
  defp d(?9), do: 9
  defp d(?a), do: 10
  defp d(?b), do: 11
  defp d(?c), do: 12
  defp d(?d), do: 13
  defp d(?e), do: 14
  defp d(?f), do: 15
  defp d(?g), do: 16
  defp d(?h), do: 17
  defp d(?j), do: 18
  defp d(?k), do: 19
  defp d(?m), do: 20
  defp d(?n), do: 21
  defp d(?p), do: 22
  defp d(?q), do: 23
  defp d(?r), do: 24
  defp d(?s), do: 25
  defp d(?t), do: 26
  defp d(?v), do: 27
  defp d(?w), do: 28
  defp d(?x), do: 29
  defp d(?y), do: 30
  defp d(?z), do: 31
  defp d(_), do: throw(:error)
end
