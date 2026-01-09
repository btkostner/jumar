defmodule Jumar.Authorization.UnauthorizedTest do
  use ExUnit.Case, async: true
  alias Jumar.Authorization.Unauthorized

  describe "message/1" do
    test "formats the error message correctly" do
      exception = %Unauthorized{
        action: :delete,
        resource: %{id: 123},
        scope: %{user_id: 1},
        params: %{force: true}
      }

      assert Exception.message(exception) ==
               "Unauthorized to perform action :delete on resource %{id: 123} with scope %{user_id: 1} and params %{force: true}"
    end
  end

  describe "exception structure" do
    test "exception has the correct fields" do
      assert %Unauthorized{} |> Map.has_key?(:action)
      assert %Unauthorized{} |> Map.has_key?(:resource)
      assert %Unauthorized{} |> Map.has_key?(:scope)
      assert %Unauthorized{} |> Map.has_key?(:params)
    end
  end
end
