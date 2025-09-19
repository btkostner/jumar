defmodule JumarWeb.DashboardLayout do
  @moduledoc """
  A layout with a sidebar and navbar for authenticated pages.
  """

  use JumarWeb, :verified_routes
  use Phoenix.Component

  import JumarWeb.AvatarComponents, only: [gravatar: 1]
  import JumarWeb.ButtonComponents, only: [touch_target: 1]
  import JumarWeb.CoreComponents, only: [flash_group: 1]

  @doc """
  Renders the sidebar layout.

  ## Examples

      <DashboardLayout.dashboard_layout flash={@flash}>
        <h1>Content</h1>
      </DashboardLayout.dashboard_layout>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def dashboard_layout(assigns) do
    ~H"""
    <div class="min-h-svh relative isolate flex w-full bg-white max-lg:flex-col dark:bg-zinc-900 lg:bg-zinc-100 lg:dark:bg-zinc-950">
      <div class="fixed inset-y-0 left-0 w-64 max-lg:hidden">
        <.sidebar current_scope={@current_scope} />
      </div>

      <el-dialog>
        <dialog id="mobile-menu" class="backdrop:bg-zinc-800/70 lg:hidden">
          <div tabindex="0" class="fixed inset-0 focus:outline-none">
            <el-dialog-panel class="fixed inset-y-0 right-0 z-50 w-full overflow-y-auto bg-white p-6 dark:bg-zinc-900 sm:ring-zinc-900/10 sm:max-w-sm sm:ring-1 sm:dark:ring-zinc-100/10">
              <button type="button" command="close" commandfor="mobile-menu" class="-m-2.5 rounded-md p-2.5 text-gray-700 dark:text-gray-400 dark:hover:text-white">
                <span class="sr-only">Close menu</span>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" data-slot="icon" aria-hidden="true" class="size-6">
                  <path d="M6 18 18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" />
                </svg>
              </button>

              <.sidebar current_scope={@current_scope} />
            </el-dialog-panel>
          </div>
        </dialog>
      </el-dialog>

      <header class="flex items-center px-4 lg:hidden">
        <div class="py-2.5">
          <button type="button" command="show-modal" commandfor="mobile-menu" class="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700 dark:text-gray-400 dark:hover:text-white">
            <span class="sr-only">Open main menu</span>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" data-slot="icon" aria-hidden="true" class="size-6">
              <path d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </button>
        </div>
        <div class="min-w-0 flex-1">navbar</div>
      </header>

      <main class="flex flex-1 flex-col pb-2 lg:min-w-0 lg:pt-2 lg:pr-2 lg:pl-64">
        <.flash_group flash={@flash} />

        <div class="grow p-6 lg:shadow-xs lg:ring-zinc-950/5 lg:rounded-lg lg:bg-white lg:p-10 lg:ring-1 lg:dark:ring-white/10 lg:dark:bg-zinc-900">
          <div class="mx-auto max-w-6xl">
            {render_slot(@inner_block)}
          </div>
        </div>
      </main>
    </div>
    """
  end

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :rest, :global

  def sidebar(assigns) do
    ~H"""
    <nav {@rest} class="flex h-full min-h-0 flex-col">
      <div class="border-zinc-950/5 [&>[data-slot=section]+[data-slot=section]]:mt-2.5 flex flex-col border-b p-4 dark:border-white/5">
        <.link href={~p"/"} class="flex items-center gap-2">
          <span class="sr-only">Jumar</span>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="512"
            height="512"
            viewBox="0 0 135.467 135.467"
            class="fill-[#8C7AE6] h-8 w-auto"
          >
            <path
              d="m142.23 165.164-34.92-86.64-.339-.502c-3.19-5.545-8.901-8.901-15.449-8.901s-12.248 3.365-15.44 8.9l-.164.338-34.93 86.804c-2.69 6.213-2.016 13.264 1.513 18.643 3.192 4.87 8.391 7.552 14.1 7.552h70.18c5.71 0 10.744-2.517 13.936-7.223 3.365-5.2 4.03-12.422 1.513-18.97zm-85.292-17.126 26.696-65.984c1.677-2.855 4.696-4.532 8.061-4.532s6.212 1.677 8.062 4.532l13.936 34.583c-13.096 17.63-33.58 29.722-56.753 31.4z"
              style="mix-blend-mode:normal;color-interpolation-filters:sRGB;fill:var(--main,#8C7AE6);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1.25367;stroke-opacity:.75"
              transform="translate(-23.814 -62.506)"
            />
          </svg>
        </.link>
      </div>

      <div class="[&>[data-slot=section]+[data-slot=section]]:mt-8 flex flex-1 flex-col overflow-y-auto p-4">

      </div>

      <div class="border-zinc-950/5 [&>[data-slot=section]+[data-slot=section]]:mt-2.5 flex flex-col border-t p-4 dark:border-white/5">
        <el-dropdown>
          <.sidebar_item>
            <.gravatar email={@current_scope.user.email} size="48" />
            <span>{@current_scope.user.email}</span>
          </.sidebar_item>

          <el-menu anchor="top start" popover class="outline-black/5 transition-discrete [--anchor-gap:--spacing(2)] w-56 origin-top-right rounded-md bg-white shadow-lg outline-1 transition data-closed:scale-95 data-closed:transform data-closed:opacity-0 data-enter:duration-100 data-enter:ease-out data-leave:duration-75 data-leave:ease-in">
            <div class="py-1">
              <.link href={~p"/users/settings"} class="block px-4 py-2 text-sm text-gray-700 focus:bg-gray-100 focus:text-gray-900 focus:outline-hidden">
                Profile
              </.link>
              <.link
                href={~p"/users/log-out"}
                method="delete"
                class="block px-4 py-2 text-sm text-gray-700 focus:bg-gray-100 focus:text-gray-900 focus:outline-hidden"
              >
                Log out
              </.link>
            </div>
          </el-menu>
        </el-dropdown>
      </div>
    </nav>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def sidebar_section(assigns) do
    ~H"""
    <div data-slot="section" {@rest} class={["flex flex-col gap-0.5", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global

  def sidebar_divider(assigns) do
    ~H"""
    <hr
      {@rest}
      class={["border-zinc-950/5 my-4 border-t dark:border-white/5 lg:-mx-4", @class]}
    />
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global

  def sidebar_spacer(assigns) do
    ~H"""
    <div aria-hidden="true" {@rest} class={["mt-8 flex-1", @class]} />
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def sidebar_heading(assigns) do
    ~H"""
    <h3
      {@rest}
      class={["text-xs/6 mb-1 px-2 font-medium text-zinc-500 dark:text-zinc-400", @class]}
    >
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  attr :current, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(href navigate patch method)
  slot :inner_block, required: true

  def sidebar_item(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex w-full items-center gap-3 rounded-lg px-2 py-2.5 text-left text-base/6 font-medium text-zinc-950 sm:py-2 sm:text-sm/5",
        "*:data-[slot=icon]:size-6 *:data-[slot=icon]:shrink-0 *:data-[slot=icon]:fill-zinc-500 sm:*:data-[slot=icon]:size-5",
        "*:last:data-[slot=icon]:ml-auto *:last:data-[slot=icon]:size-5 sm:*:last:data-[slot=icon]:size-4",
        "*:data-[slot=avatar]:-m-0.5 *:data-[slot=avatar]:size-7 sm:*:data-[slot=avatar]:size-6",
        "data-hover:bg-zinc-950/5 data-hover:*:data-[slot=icon]:fill-zinc-950",
        "data-active:bg-zinc-950/5 data-active:*:data-[slot=icon]:fill-zinc-950",
        "data-current:*:data-[slot=icon]:fill-zinc-950",
        "dark:text-white dark:*:data-[slot=icon]:fill-zinc-400",
        "dark:data-hover:bg-white/5 dark:data-hover:*:data-[slot=icon]:fill-white",
        "dark:data-active:bg-white/5 dark:data-active:*:data-[slot=icon]:fill-white",
        "dark:data-current:*:data-[slot=icon]:fill-white"
      ])

    ~H"""
    <span class={["relative", @class]}>
      <span
        :if={@current}
        class="absolute inset-y-2 -left-4 w-0.5 rounded-full bg-zinc-950 dark:bg-white"
      />
      <%= if @rest[:href] || @rest[:navigate] || @rest[:patch] do %>
        <.link
          {@rest}
          class={@classes}
          data-current={if @current, do: "true"}
        >
          <.touch_target><%= render_slot(@inner_block) %></.touch_target>
        </.link>
      <% else %>
        <button
          {@rest}
          class={["cursor-default", @classes]}
          data-current={if @current, do: "true"}
        >
          <.touch_target><%= render_slot(@inner_block) %></.touch_target>
        </button>
      <% end %>
    </span>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def sidebar_label(assigns) do
    ~H"""
    <span {@rest} class={["truncate", @class]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
