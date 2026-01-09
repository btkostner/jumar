defprotocol Jumar.Authorization.Policy do
  @moduledoc """
  Responsible for defining authorization policies for different resources.

  Implementations of this protocol should provide the logic to determine
  whether a specific action can be performed on a resource given the
  current scope (e.g., user roles, permissions, etc.) and optional parameters.
  It should _not_ do any data fetching, as this will cause N+1 query issues.
  Instead, all necessary data should be preloaded and passed in as part of
  the resource or parameters.

  See the `Jumar.Authorization` module for functions that utilize this protocol,
  as well as more examples of best practices.
  """

  @fallback_to_any true

  @doc """
  Determines if the given action can be performed on the resource with the
  provided current scope. This function should return `true` if the action
  is allowed, and `false` otherwise.
  """
  @spec permit?(
          resource :: t(),
          action :: atom(),
          scope :: Jumar.Scope.t(),
          params :: map()
        ) ::
          boolean()
  def permit?(resource, action, scope, params)
end

defimpl Jumar.Authorization.Policy, for: Any do
  @doc """
  Default implementation of `can?/3` that denies all actions.
  """
  def permit?(_resource, _action, _scope, _params), do: false
end

defimpl Jumar.Authorization.Policy, for: List do
  @doc """
  All given lists must return `true` for every resource in the
  list for the action to be allowed.
  """
  def permit?(resources, action, scope, params) do
    Enum.all?(resources, &Jumar.Authorization.Policy.permit?(&1, action, scope, params))
  end
end
