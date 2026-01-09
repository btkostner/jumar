defmodule Jumar.AuthorizationTest do
  use ExUnit.Case, async: true

  alias Jumar.Authorization
  alias Jumar.Scope

  defmodule Resource do
    defstruct [:owner_id]
  end

  defimpl Jumar.Authorization.Policy, for: Resource do
    def permit?(_resource, _action, _scope, %{allowed: true}), do: true
    def permit?(_resource, :delete, %{role: :admin}, _params), do: true
    def permit?(_resource, :read, _scope, _params), do: true
    def permit?(%{owner_id: user_id}, :update, %{user: %{id: user_id}}, _params), do: true
    def permit?(_resource, _action, _scope, _params), do: false
  end

  @admin_scope %Scope{role: :admin, user: %Jumar.Accounts.User{id: 2}}
  @user_scope %Scope{role: :user, user: %Jumar.Accounts.User{id: 1}}
  @other_scope %Scope{role: :user}

  describe "can?/4" do
    test "returns true when authorized" do
      resource = %Resource{owner_id: 2}

      assert Authorization.can?(@admin_scope, :delete, resource)
      assert Authorization.can?(@user_scope, :read, resource)
    end

    test "returns false when unauthorized" do
      resource = %Resource{owner_id: 2}

      refute Authorization.can?(@user_scope, :delete, resource)
      refute Authorization.can?(@user_scope, :create, resource)
    end

    test "checks specific logic in policy" do
      resource = %Resource{owner_id: 1}

      assert Authorization.can?(@user_scope, :update, resource)
      refute Authorization.can?(@other_scope, :update, resource)
    end

    test "passes params to policy" do
      resource = %Resource{}

      assert Authorization.can?(@other_scope, :delete, resource, %{allowed: true})
      refute Authorization.can?(@other_scope, :delete, resource, %{allowed: false})
    end
  end

  describe "can!/4" do
    test "returns :ok when authorized" do
      resource = %Resource{}

      assert Authorization.can!(@admin_scope, :delete, resource) == :ok
    end

    test "raises Unauthorized exception when unauthorized" do
      resource = %Resource{}

      assert_raise Jumar.Authorization.Unauthorized, fn ->
        Authorization.can!(@user_scope, :delete, resource)
      end
    end

    test "exception includes details" do
      resource = %Resource{}
      action = :delete
      params = %{foo: "bar"}

      try do
        Authorization.can!(@user_scope, action, resource, params)
      rescue
        e in Jumar.Authorization.Unauthorized ->
          assert e.action == action
          assert e.resource == resource
          assert e.scope == @user_scope
          assert e.params == params
      end
    end
  end
end
