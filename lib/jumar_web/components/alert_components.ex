defmodule JumarWeb.AlertComponents do
  @moduledoc """
  Provides a nice looking notification block.
  """

  use Phoenix.Component

  @doc """
  Renders an alert component.

  ## Examples

      <.alert title="Error">
        <p>An error has occurred!</p>
      </.alert>
  """
  attr :title, :string

  slot :inner_block, required: true

  def alert(assigns) do
    ~H"""
    <div class="rounded-md bg-yellow-50 p-4">
      <div class="flex">
        <div class="shrink-0">
          <svg viewBox="0 0 20 20" fill="currentColor" data-slot="icon" aria-hidden="true" class="size-5 text-yellow-400">
            <path d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495ZM10 5a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 10 5Zm0 9a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z" clip-rule="evenodd" fill-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-yellow-800">{@title}</h3>
          <div class="mt-2 text-sm text-yellow-700">
            {render_slot(@inner_block)}
          </div>
        </div>
      </div>
    </div>
    """
  end
end
