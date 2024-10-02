defmodule Jumar.Types.TypeIdTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Jumar.Types.TypeId

  doctest Jumar.Types.TypeId, import: true

  defp prefix_generator,
    do: StreamData.string(?a..?z, min_length: 1, max_length: 62)

  defp uuid_generator,
    do: StreamData.repeatedly(&Jumar.Types.UUIDv7.generate/0)

  defp valid_prefix?(""), do: false

  defp valid_prefix?(binary) do
    binary
    |> :binary.bin_to_list()
    |> Enum.all?(&(&1 in 97..122))
  end

  describe "type/1" do
    test "returns Ecto.UUID.type/1" do
      assert Ecto.UUID.type() == TypeId.type(%{})
    end
  end

  describe "init/1" do
    test "asserts prefix is given" do
      assert TypeId.init(prefix: "valid")
      assert_raise ArgumentError, fn -> TypeId.init([]) end
    end

    property "asserts a valid prefix is given" do
      check all prefix <- prefix_generator() do
        assert %{prefix: ^prefix} = TypeId.init(prefix: prefix)
      end
    end

    property "raises ArgumentError on invalid prefix given" do
      check all bad_prefix <- StreamData.filter(StreamData.binary(), &(not valid_prefix?(&1))) do
        assert_raise ArgumentError, fn -> TypeId.init(prefix: bad_prefix) end
      end
    end
  end

  describe "crockford_encode32/1" do
    property "can encode UUIDs" do
      check all uuid <- uuid_generator() do
        {:ok, dumped_uuid} = Jumar.Types.UUIDv7.dump(uuid)
        assert is_binary(TypeId.crockford_encode32(dumped_uuid))
      end
    end
  end

  describe "crockford_encode32/1 and crockford_decode32/1" do
    property "functions are inverse" do
      check all uuid <- uuid_generator() do
        {:ok, dumped_uuid} = Jumar.Types.UUIDv7.dump(uuid)
        assert ^dumped_uuid = TypeId.crockford_decode32(TypeId.crockford_encode32(dumped_uuid))
      end
    end
  end
end
