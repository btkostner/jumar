defmodule JumarWeb.AuthLayout do
  @moduledoc """
  A very basic centered page layout for authentication
  pages like the sign in and register pages.
  """

  use Phoenix.Component

  @doc """
  Renders the auth layout.

  ## Examples

      <AuthLayout.auth_layout flash={@flash}>
        <h1>Content</h1>
      </AuthLayout.auth_layout>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def auth_layout(assigns) do
    ~H"""
    <main class="min-h-dvh flex grow items-center justify-center p-6 lg:p-10">
      {render_slot(@inner_block)}
    </main>
    """
  end
end
