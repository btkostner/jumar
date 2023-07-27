defmodule Jumar.Types.UUIDv7Test do
  use Jumar.DataCase, async: true
  use ExUnitProperties

  alias Jumar.Types.UUIDv7

  doctest Jumar.Types.UUIDv7, import: true

  defp uuid_generator(),
    do: StreamData.repeatedly(&UUIDv7.generate/0)

  describe "type/0" do
    test "uses :uuid database type" do
      assert :uuid = UUIDv7.type()
    end
  end

  describe "bingenerate/1" do
    property "generates a valid UUID" do
      check all uuid <- uuid_generator() do
        assert <<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = uuid
      end
    end
  end
end
