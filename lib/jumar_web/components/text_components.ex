defmodule JumarWeb.TextComponents do
  @moduledoc """
  For all the lorem ipsum in your Figma designs that
  you're definitely going to replace with real copy before launch.
  """

  use Phoenix.Component

  @doc """
  Paragraph component for displaying text content.
  """
  attr :class, :string, default: ""
  attr :rest, :global

  slot :inner_block, required: true

  def text(assigns) do
    ~H"""
    <p
      data-slot="text"
      class={[@class, "text-base/6 text-zinc-500 dark:text-zinc-400 sm:text-sm/6"]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Inner text link component.
  """
  attr :class, :string, default: ""
  attr :rest, :global

  slot :inner_block, required: true

  def text_link(assigns) do
    ~H"""
    <.link
      class={[@class, "decoration-zinc-950/50 text-zinc-950 underline data-hover:decoration-zinc-950 dark:decoration-white/50 dark:text-white dark:data-hover:decoration-white"]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Strong text component.
  """
  attr :class, :string, default: ""
  attr :rest, :global

  slot :inner_block, required: true

  def strong(assigns) do
    ~H"""
    <strong
      class={[@class, "font-medium text-zinc-950 dark:text-white"]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </strong>
    """
  end

  @doc """
  Code component for displaying inline code snippets.
  """
  attr :class, :string, default: ""
  attr :rest, :global

  slot :inner_block, required: true

  def code(assigns) do
    ~H"""
    <code
      class={[@class, "border-zinc-950/10 bg-zinc-950/2.5 rounded-sm border px-0.5 text-sm font-medium text-zinc-950 dark:border-white/20 dark:bg-white/5 dark:text-white sm:text-[0.8125rem]"]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </code>
    """
  end
end
