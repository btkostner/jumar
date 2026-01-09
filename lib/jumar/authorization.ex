defmodule Jumar.Authorization do
  @moduledoc """
  Provides functions to check authorization policies for various resources
  that implement the `Jumar.Authorization.Policy` protocol.

  ## Actions

  Actions are represented as atoms and can be anything, but to keep things
  managable and consistent, we recommend using CRUD actions as a base set:

    * `:create`
    * `:read`
    * `:update`
    * `:delete`
  """

  alias Jumar.Authorization.Policy

  @doc """
  Checks if the current scope can performance the given action
  on the given resource with optional parameters.

  ## Examples

      iex> Jumar.Authorization.can?(%Scope{role: :admin}, :delete, %Resource{})
      true

      iex> Jumar.Authorization.can?(%Scope{role: :user}, :create, %Resource{})
      false

      iex> Jumar.Authorization.can?(%Scope{role: :user}, :create, TheSun, %{degress: 27_000_000})
      false

  """
  @spec can?(
          scope :: Jumar.Scope.t(),
          action :: atom(),
          resource :: Policy.t(),
          params :: map()
        ) ::
          boolean()
  def can?(scope, action, resource, params \\ %{}) do
    Policy.permit?(resource, action, scope, params)
  end

  @doc """
  Checks if the scope can performance the given action
  on the given resource with optional parameters. Raises a
  `Jumar.Authorization.Unauthorized` error if not allowed.

  ## Examples

      iex> Jumar.Authorization.can!(%Scope{role: :admin}, :delete, %Resource{})
      :ok

      iex> Jumar.Authorization.can!(%Scope{role: :user}, :create, %Resource{})
      ** (Jumar.Authorization.Unauthorized)

  """
  def can!(scope, action, resource, params \\ %{}) do
    if can?(scope, action, resource, params) do
      :ok
    else
      raise Jumar.Authorization.Unauthorized,
        action: action,
        resource: resource,
        scope: scope,
        params: params
    end
  end
end
