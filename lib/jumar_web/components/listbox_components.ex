defmodule JumarWeb.ListboxComponents do
  @moduledoc """
  Provides listbox components.
  """

  use Phoenix.Component

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def listbox(assigns) do
    ~H"""
    <div {@rest} class={["group relative", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :placeholder
  slot :inner_block, required: true

  def listbox_button(assigns) do
    ~H"""
    <div
      {@rest}
      class={["group relative block w-full", "before:rounded-[calc(var(--radius-lg)-1px)] before:absolute before:inset-px before:bg-white before:shadow-sm", "dark:before:hidden", "focus:outline-hidden", "after:pointer-events-none after:absolute after:inset-0 after:rounded-lg after:ring-inset after:ring-transparent after:data-focus:ring-2 after:data-focus:ring-blue-500", "data-disabled:opacity-50 before:data-disabled:bg-zinc-950/5 before:data-disabled:shadow-none", @class]}
    >
      <span
        class={["py-[calc(var(--spacing-2-5)-1px)] relative block w-full appearance-none rounded-lg sm:py-[calc(var(--spacing-1-5)-1px)]", "min-h-11 sm:min-h-9", "pr-[calc(var(--spacing-7)-1px)] pl-[calc(var(--spacing-3-5)-1px)] sm:pl-[calc(var(--spacing-3)-1px)]", "text-base/6 text-left text-zinc-950 forced-colors:text-[CanvasText] placeholder:text-zinc-500 dark:text-white sm:text-sm/6", "border-zinc-950/10 border group-data-active:border-zinc-950/20 group-data-hover:border-zinc-950/20 dark:border-white/10 dark:group-data-active:border-white/20 dark:group-data-hover:border-white/20", "bg-transparent dark:bg-white/5", "group-data-hover:group-data-invalid:border-red-500 group-data-invalid:border-red-500 dark:data-hover:group-data-invalid:border-red-600 dark:group-data-invalid:border-red-600", "group-data-disabled:border-zinc-950/20 group-data-disabled:opacity-100 dark:group-data-disabled:border-white/15 dark:group-data-disabled:bg-white/2.5 dark:group-data-disabled:data-hover:border-white/15"]}
      >
        <%= render_slot(@inner_block) %>
        <span :if={@placeholder != []} class="block truncate text-zinc-500">
          <%= render_slot(@placeholder) %>
        </span>
      </span>
      <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
        <svg
          class="size-5 stroke-zinc-500 forced-colors:stroke-[CanvasText] group-data-disabled:stroke-zinc-600 dark:stroke-zinc-400 sm:size-4"
          viewBox="0 0 16 16"
          aria-hidden="true"
          fill="none"
        >
          <path d="M5.75 10.75L8 13L10.25 10.75" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
          <path d="M10.25 5.25L8 3L5.75 5.25" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </span>
    </div>
    """
  end

  attr :show, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def listbox_options(assigns) do
    ~H"""
    <div
      :if={@show}
      {@rest}
      class={["[--anchor-offset:-1.625rem] [--anchor-padding:var(--spacing-4)] sm:[--anchor-offset:-1.375rem]", "min-w-[calc(var(--button-width)+1.75rem)] isolate w-max select-none scroll-py-1 rounded-xl p-1", "outline outline-transparent focus:outline-hidden", "overflow-y-scroll overscroll-contain", "bg-white/75 backdrop-blur-xl dark:bg-zinc-800/75", "ring-zinc-950/10 shadow-lg ring-1 dark:ring-white/10 dark:ring-inset", @class]}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :selected, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def listbox_option(assigns) do
    assigns =
      assign(assigns, :shared_classes, [
        "flex min-w-0 items-center",
        "*:data-[slot=icon]:size-5 *:data-[slot=icon]:shrink-0 sm:*:data-[slot=icon]:size-4",
        "*:data-[slot=icon]:text-zinc-500 group-data-focus/option:*:data-[slot=icon]:text-white dark:*:data-[slot=icon]:text-zinc-400",
        "forced-colors:*:data-[slot=icon]:text-[CanvasText] forced-colors:group-data-focus/option:*:data-[slot=icon]:text-[Canvas]",
        "*:data-[slot=avatar]:-mx-0.5 *:data-[slot=avatar]:size-6 sm:*:data-[slot=avatar]:size-5"
      ])

    ~H"""
    <div
      {@rest}
      class={["group/option grid-cols-[var(--spacing-5)_1fr] grid cursor-default items-baseline gap-x-2 rounded-lg py-2.5 pr-3.5 pl-2 sm:grid-cols-[var(--spacing-4)_1fr] sm:py-1.5 sm:pr-3 sm:pl-1.5", "text-base/6 text-zinc-950 forced-colors:text-[CanvasText] dark:text-white sm:text-sm/6", "outline-hidden data-focus:bg-blue-500 data-focus:text-white", "forced-color-adjust-none forced-colors:data-focus:bg-[Highlight] forced-colors:data-focus:text-[HighlightText]", "data-disabled:opacity-50", @class]}
    >
      <svg
        :if={@selected}
        class="size-5 relative hidden self-center stroke-current group-data-selected/option:inline sm:size-4"
        viewBox="0 0 16 16"
        fill="none"
        aria-hidden="true"
      >
        <path d="M4 8.5l3 3L12 4" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
      </svg>
      <span class={[@shared_classes, "col-start-2"]}>
        <%= render_slot(@inner_block) %>
      </span>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def listbox_label(assigns) do
    ~H"""
    <span {@rest} class={["ml-2.5 truncate first:ml-0 sm:ml-2 sm:first:ml-0", @class]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def listbox_description(assigns) do
    ~H"""
    <span
      {@rest}
      class={["flex flex-1 overflow-hidden text-zinc-500 group-data-focus/option:text-white before:w-2 before:min-w-0 before:shrink dark:text-zinc-400", @class]}
    >
      <span class="flex-1 truncate"><%= render_slot(@inner_block) %></span>
    </span>
    """
  end
end
