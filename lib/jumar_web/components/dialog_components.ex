defmodule JumarWeb.DialogComponents do
  @moduledoc """
  Provides dialog components.
  """

  use Phoenix.Component

  import JumarWeb.TextComponents

  @sizes %{
    "xs" => "sm:max-w-xs",
    "sm" => "sm:max-w-sm",
    "md" => "sm:max-w-md",
    "lg" => "sm:max-w-lg",
    "xl" => "sm:max-w-xl",
    "2xl" => "sm:max-w-2xl",
    "3xl" => "sm:max-w-3xl",
    "4xl" => "sm:max-w-4xl",
    "5xl" => "sm:max-w-5xl"
  }

  attr :size, :string, values: Map.keys(@sizes), default: "lg"
  attr :show, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog(assigns) do
    ~H"""
    <div
      :if={@show}
      {@rest}
      class={["fixed inset-0 z-50 overflow-y-auto", @class]}
      aria-labelledby="dialog-title"
      role="dialog"
      aria-modal="true"
    >
      <div class="bg-zinc-950/25 fixed inset-0 dark:bg-zinc-950/50" />
      <div class="fixed inset-0 w-screen overflow-y-auto pt-6 sm:pt-0">
        <div class="grid-rows-[1fr_auto] grid min-h-full justify-items-center sm:grid-rows-[1fr_auto_3fr] sm:p-4">
          <div
            class={[@sizes[@size], "p-[--gutter] ring-zinc-950/10 [--gutter:var(--spacing-8)] row-start-2 w-full min-w-0 rounded-t-3xl bg-white shadow-lg ring-1 forced-colors:outline dark:ring-white/10 dark:bg-zinc-900 sm:mb-auto sm:rounded-2xl"]}
          >
            <%= render_slot(@inner_block) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_title(assigns) do
    ~H"""
    <h2
      id="dialog-title"
      {@rest}
      class={["text-lg/6 text-balance font-semibold text-zinc-950 dark:text-white sm:text-base/6", @class]}
    >
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_description(assigns) do
    ~H"""
    <.text {@rest} class={Enum.join(["text-pretty mt-2", @class], "  ")}>
      <%= render_slot(@inner_block) %>
    </.text>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_body(assigns) do
    ~H"""
    <div {@rest} class={["mt-6", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def dialog_actions(assigns) do
    ~H"""
    <div
      {@rest}
      class={["mt-8 flex flex-col-reverse items-center justify-end gap-3 *:w-full sm:flex-row sm:*:w-auto", @class]}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
