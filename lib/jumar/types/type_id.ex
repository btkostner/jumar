defmodule Jumar.Types.TypeId do
  @moduledoc """
  An Elixir implementation of [typeid][typeid] using `Jumar.Types.UUIDv7`
  or another Ecto UUID module. This allows using UUIDs as the database
  primary key, while transparently converting to a Stripe like ID
  (`user_2x4y6z8a0b1c2d3e4f5g6h7j8k`) by `Ecto`.

  A lot of the code here was taken from the amazing work done by
  sloanelybutsurely on the [typeid-elixir][typeid-elixir] package.

  [typeid]: https://github.com/jetpack-io/typeid
  [typeid-elixir]: https://github.com/sloanelybutsurely/typeid-elixir/
  """

  use Ecto.ParameterizedType

  crockford_alphabet = ~c"0123456789abcdefghjkmnpqrstvwxyz"

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
  A string representation of a UUID.
  """
  @type uuid :: <<_::128>>

  @typedoc """
  The parameters for a type id. This only includes the prefix itself.
  """
  @type params :: %{prefix: prefix(), uuid_module: module()}

  @doc """
  Returns the underlying schema type for a prefixed uuid. This is a basic UUID
  under the hood and is stored the same way an `Ecto.UUID` would be.
  """
  @impl Ecto.ParameterizedType
  @spec type(params()) :: :uuid
  def type(_params), do: :uuid

  @doc """
  Converts the given options to `t:params`. Raises if the prefix is missing or
  not binary.
  """
  @impl Ecto.ParameterizedType
  @spec init(Ecto.ParameterizedType.opts()) :: params()
  def init(opts) do
    opts = Keyword.put_new(opts, :uuid_module, Jumar.Types.UUIDv7)

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
           |> Enum.all?(&ascii_lowercase?/1) do
      raise ArgumentError,
        message: "#{__MODULE__} prefix must only container lowercase ascii characters."
    end

    with {:error, _} <- Code.ensure_compiled(Keyword.get(opts, :uuid_module)) do
      raise ArgumentError,
        message: "#{__MODULE__} was given an invalid UUID module."
    end

    Enum.into(opts, %{})
  end

  defp ascii_lowercase?(char) when char in 97..122, do: true
  defp ascii_lowercase?(_), do: false

  @doc """
  Casts a given input to a type id.
  """
  @impl Ecto.ParameterizedType
  @spec cast(term(), params()) :: {:ok, t()} | :error
  def cast(nil, _params), do: {:ok, nil}

  def cast(data, %{prefix: prefix}) when is_binary(data) do
    if String.starts_with?(data, prefix <> "_") do
      {:ok, data}
    else
      :error
    end
  end

  def cast(_data, _params), do: :error

  @doc """
  Loads data from the database to a type id.
  """
  @impl Ecto.ParameterizedType
  @spec load(any(), function(), params()) :: {:ok, any()} | :error
  def load(nil, _loader, _params), do: {:ok, nil}

  def load(uuid, _loader, %{prefix: prefix}) when is_binary(uuid) do
    case crockford_encode32(uuid) do
      :error -> :error
      encoded_uuid -> {:ok, prefix <> "_" <> encoded_uuid}
    end
  end

  def load(_data, _loader, _params), do: :error

  @doc """
  Dumps the given type id to an Ecto native type.
  """
  @impl Ecto.ParameterizedType
  @spec dump(any(), function(), params()) :: {:ok, any()} | :error
  def dump(nil, _dumper, _params), do: {:ok, nil}

  def dump(data, _dumper, %{prefix: prefix}) when is_binary(data) do
    uuid = String.trim_leading(data, prefix <> "_")

    case crockford_decode32(uuid) do
      :error -> :error
      decoded_uuid -> {:ok, decoded_uuid}
    end
  end

  def dump(_data, _dumper, _params), do: :error

  @doc """
  Checks if the two type ids are equal. This is a basic `==` equality
  checker.
  """
  @impl Ecto.ParameterizedType
  @spec equal?(any(), any(), params()) :: boolean()
  def equal?(a, b, _params), do: a == b

  @doc """
  Generates a new type id.
  """
  @spec generate(params()) :: t()
  def generate(%{prefix: prefix, uuid_module: uuid_module}) do
    {:ok, dumped_uuid} = uuid_module.dump(uuid_module.generate())
    prefix <> "_" <> crockford_encode32(dumped_uuid)
  end

  @doc false
  @impl Ecto.ParameterizedType
  @spec autogenerate(params()) :: t()
  def autogenerate(params), do: generate(params)

  @doc """
  Base32 encodes a UUID with Crockford's lowercase alphabet.

  ## Examples

      iex> with {:ok, dumped_uuid} <- Jumar.Types.UUIDv7.dump("0110c853-1d09-52d8-d73e-1194e95b5f19") do
      ...>   crockford_encode32(dumped_uuid)
      ...> end
      "0123456789abcdefghjkmnpqrs"

      iex> with {:ok, dumped_uuid} <- Jumar.Types.UUIDv7.dump("01890a5d-ac96-774b-bcce-b302099a8057") do
      ...>   crockford_encode32(dumped_uuid)
      ...> end
      "01h455vb4pex5vsknk084sn02q"

      iex> crockford_encode32("invalid uuid")
      :error

  """
  @spec crockford_encode32(binary()) :: binary() | :error
  def crockford_encode32(
        <<c1::3, c2::5, c3::5, c4::5, c5::5, c6::5, c7::5, c8::5, c9::5, c10::5, c11::5, c12::5,
          c13::5, c14::5, c15::5, c16::5, c17::5, c18::5, c19::5, c20::5, c21::5, c22::5, c23::5,
          c24::5, c25::5, c26::5>>
      ) do
    <<e(c1)::8, e(c2)::8, e(c3)::8, e(c4)::8, e(c5)::8, e(c6)::8, e(c7)::8, e(c8)::8, e(c9)::8,
      e(c10)::8, e(c11)::8, e(c12)::8, e(c13)::8, e(c14)::8, e(c15)::8, e(c16)::8, e(c17)::8,
      e(c18)::8, e(c19)::8, e(c20)::8, e(c21)::8, e(c22)::8, e(c23)::8, e(c24)::8, e(c25)::8,
      e(c26)::8>>
  rescue
    _ -> :error
  end

  def crockford_encode32(_), do: :error

  @compile {:inline, [e: 1]}
  defp e(byte) do
    elem({unquote_splicing(crockford_alphabet)}, byte)
  end

  @doc """
  Base32 decodes a UUID with Crockford's lowercase alphabet.

  ## Examples

      iex> "0123456789abcdefghjkmnpqrs"
      ...> |> crockford_decode32()
      ...> |> Jumar.Types.UUIDv7.load()
      {:ok, "0110c853-1d09-52d8-d73e-1194e95b5f19"}

      iex> "01h455vb4pex5vsknk084sn02q"
      ...> |> crockford_decode32()
      ...> |> Jumar.Types.UUIDv7.load()
      {:ok, "01890a5d-ac96-774b-bcce-b302099a8057"}

      iex> crockford_decode32("invalid type id")
      :error

  """
  @spec crockford_decode32(binary()) :: binary() | :error
  def crockford_decode32(
        <<c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19,
          c20, c21, c22, c23, c24, c25, c26>>
      )
      when c1 in ?0..?7 do
    <<d(c1)::3, d(c2)::5, d(c3)::5, d(c4)::5, d(c5)::5, d(c6)::5, d(c7)::5, d(c8)::5, d(c9)::5,
      d(c10)::5, d(c11)::5, d(c12)::5, d(c13)::5, d(c14)::5, d(c15)::5, d(c16)::5, d(c17)::5,
      d(c18)::5, d(c19)::5, d(c20)::5, d(c21)::5, d(c22)::5, d(c23)::5, d(c24)::5, d(c25)::5,
      d(c26)::5>>
  rescue
    _ -> :error
  end

  def crockford_decode32(_), do: :error

  @compile {:inline, [d: 1]}
  for {char, byte} <- Enum.with_index(crockford_alphabet) do
    defp d(unquote(char)), do: unquote(byte)
  end
end
