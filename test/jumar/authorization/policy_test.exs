defmodule Jumar.Authorization.PolicyTest do
  use ExUnit.Case, async: true

  alias Jumar.Authorization.Policy
  alias Jumar.Scope

  defmodule NoPolicyStruct do
    defstruct []
  end

  defmodule ListPolicyStruct do
    defstruct [:allowed]
  end

  defimpl Jumar.Authorization.Policy, for: ListPolicyStruct do
    def permit?(resource, _action, _scope, _params) do
      resource.allowed
    end
  end

  describe "Any implementation" do
    test "returns false for any struct without explicit implementation" do
      resource = %NoPolicyStruct{}
      scope = %Scope{}

      refute Policy.permit?(resource, :read, scope, %{})
      refute Policy.permit?(resource, :delete, scope, %{})
    end

    test "returns false for atoms without explicit implementation" do
      scope = %Scope{}

      refute Policy.permit?(SomeRandomModule, :read, scope, %{})
    end
  end

  describe "Enum implementation" do
    test "returns true if all items in list are allowed" do
      scope = %Scope{}

      resources = [
        %ListPolicyStruct{allowed: true},
        %ListPolicyStruct{allowed: true}
      ]

      assert Policy.permit?(resources, :read, scope, %{})
    end

    test "returns false if any item in list is not allowed" do
      scope = %Scope{}

      resources = [
        %ListPolicyStruct{allowed: true},
        %ListPolicyStruct{allowed: false}
      ]

      refute Policy.permit?(resources, :read, scope, %{})
    end

    test "returns true for empty list" do
      scope = %Scope{}
      resources = []

      assert Policy.permit?(resources, :read, scope, %{})
    end
  end
end
