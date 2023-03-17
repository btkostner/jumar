defmodule Jumar.Types.PrefixedUUIDTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Jumar.Types.PrefixedUUID

  @valid_uuid_chars ~c(abcdefABCDEF0123456789)

  def prefix_generator() do
    StreamData.string(:alphanumeric, min_length: 1)
  end

  def uuid_generator do
    ExUnitProperties.gen all one <- StreamData.string(@valid_uuid_chars, length: 8),
                             two <- StreamData.string(@valid_uuid_chars, length: 4),
                             three <- StreamData.string(@valid_uuid_chars, length: 4),
                             four <- StreamData.string(@valid_uuid_chars, length: 4),
                             five <- StreamData.string(@valid_uuid_chars, length: 12) do
      Enum.join([one, two, three, four, five], "-")
    end
  end

  def prefixed_uuid_generator do
    ExUnitProperties.gen all prefix <- prefix_generator(),
                             uuid <- uuid_generator() do
      prefix <> "_" <> uuid
    end
  end

  property "type/1 returns :uuid type" do
    check all prefix <- prefix_generator() do
      assert :uuid = PrefixedUUID.type(%{prefix: prefix})
    end
  end

  describe "cast/2" do
    property "casts a UUID value to a PrefixedUUID value" do
      check all prefix <- prefix_generator(),
                uuid <- uuid_generator() do
        assert {:ok, casted_value} = PrefixedUUID.cast(uuid, %{prefix: prefix})
        assert String.starts_with?(casted_value, prefix)
      end
    end

    property "errors on invalid data" do
      check all prefix <- prefix_generator(),
                value <- StreamData.term() do
        assert :error = PrefixedUUID.cast(value, %{prefix: prefix})
      end
    end
  end

  describe "equal?/3" do
    property "similar values return true" do
      check all prefix <- prefix_generator(),
                prefixed_uuid <- prefixed_uuid_generator() do
        assert PrefixedUUID.equal?(prefixed_uuid, prefixed_uuid, %{prefix: prefix})
      end
    end

    property "unique values return false" do
      check all prefix <- prefix_generator(),
                a <- prefixed_uuid_generator(),
                b <- prefixed_uuid_generator() do
        refute PrefixedUUID.equal?(a, b, %{prefix: prefix})
      end
    end
  end

  describe "generate/1" do
    property "prefix is put before UUID" do
      check all prefix <- prefix_generator() do
        assert String.match?(
                 PrefixedUUID.generate(%{prefix: prefix}),
                 ~r/^\S+_[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/
               )
      end
    end
  end
end
