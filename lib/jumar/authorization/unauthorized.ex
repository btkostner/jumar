defmodule Jumar.Authorization.Unauthorized do
  @moduledoc """
  Exception raised when an authorization check fails.

  This exception is typically raised by functions in the
  `Jumar.Authorization` module when a user attempts to perform
  an action they are not authorized to perform.

  ## Fields

    * `:action` - The action that was attempted (e.g., `:create`, `:read`, etc.).
    * `:resource` - The resource on which the action was attempted.
    * `:scope` - The current scope or user context attempting the action.
    * `:params` - Additional parameters related to the authorization check.

  ## Example

      raise Jumar.Authorization.Unauthorized,
        action: :delete,
        resource: %Important{},
        scope: %Scope{role: :user},
        params: %{}
  """

  defexception [:action, :resource, :scope, :params]

  @impl true
  def message(exception) do
    "Unauthorized to perform action #{inspect(exception.action)} " <>
      "on resource #{inspect(exception.resource)} " <>
      "with scope #{inspect(exception.scope)} " <>
      "and params #{inspect(exception.params)}"
  end
end
