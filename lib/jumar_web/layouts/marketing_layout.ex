defmodule JumarWeb.MarketingLayout do
  @moduledoc """
  A layout with a stacked top navigation bar and footer.
  This is usuaully used for unauthenticated pages like the homepage
  or legal pages before the user accesses the dashboard.
  """

  use JumarWeb, :verified_routes
  use Phoenix.Component

  import JumarWeb.CoreComponents, only: [flash: 1, icon: 1]

  alias Phoenix.LiveView.JS

  @doc """
  Renders the marketing layout.

  ## Examples

      <MarktingLayout.marketing_layout flash={@flash}>
        <h1>Content</h1>
      </MarktingLayout.marketing_layout>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def marketing_layout(assigns) do
    ~H"""
    <header class="bg-white dark:bg-zinc-900">
      <nav aria-label="Global" class="mx-auto flex max-w-7xl items-center justify-between p-6 lg:px-8">
        <div class="flex items-center gap-x-12">
          <.link href={~p"/"} class="-m-1.5 p-1.5">
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
          <div class="hidden lg:flex lg:gap-x-12">
            <a
              href="https://hexdocs.pm/elixir"
              target="_blank"
              class="text-sm/6 font-semibold text-gray-900 dark:text-white"
            >
              Elixir
            </a>
            <a
              href="https://hexdocs.pm/phoenix"
              target="_blank"
              class="text-sm/6 font-semibold text-gray-900 dark:text-white"
            >
              Phoenix
            </a>
            <a
              href="https://jumar.btkostner.io"
              target="_blank"
              class="text-sm/6 font-semibold text-gray-900 dark:text-white"
            >
              Jumar
            </a>
          </div>
        </div>
        <div class="flex items-center gap-x-6">
          <.theme_toggle />
          <div class="flex lg:hidden">
            <button type="button" command="show-modal" commandfor="mobile-menu" class="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700 dark:text-gray-400 dark:hover:text-white">
              <span class="sr-only">Open main menu</span>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" data-slot="icon" aria-hidden="true" class="size-6">
                <path d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" stroke-linecap="round" stroke-linejoin="round" />
              </svg>
            </button>
          </div>
          <div class="hidden lg:flex lg:gap-x-4">
            <%= if @current_scope.user do %>
              <.link
                href={~p"/users/log-out"}
                method="delete"
                class="text-sm/6 font-semibold text-gray-900 dark:text-white"
              >
                Log out
              </.link>
              <.link href={~p"/users/settings"} class="text-sm/6 font-semibold text-gray-900 dark:text-white">
                Profile <span aria-hidden="true">&rarr;</span>
              </.link>
            <% else %>
              <.link href={~p"/users/register"} class="text-sm/6 font-semibold text-gray-900 dark:text-white">
                Register
              </.link>
              <.link href={~p"/users/log-in"} class="text-sm/6 font-semibold text-gray-900 dark:text-white">
                Log in <span aria-hidden="true">&rarr;</span>
              </.link>
            <% end %>
          </div>
        </div>
      </nav>
      <el-dialog>
        <dialog id="mobile-menu" class="backdrop:bg-zinc-800/70 lg:hidden">
          <div tabindex="0" class="fixed inset-0 focus:outline-none">
            <el-dialog-panel class="fixed inset-y-0 right-0 z-50 w-full overflow-y-auto bg-white p-6 dark:bg-zinc-900 sm:ring-zinc-900/10 sm:max-w-sm sm:ring-1 sm:dark:ring-zinc-100/10">
              <div class="flex items-center justify-between">
                <.link href={~p"/"} class="-m-1.5 p-1.5">
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

                <button type="button" command="close" commandfor="mobile-menu" class="-m-2.5 rounded-md p-2.5 text-gray-700 dark:text-gray-400 dark:hover:text-white">
                  <span class="sr-only">Close menu</span>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" data-slot="icon" aria-hidden="true" class="size-6">
                    <path d="M6 18 18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" />
                  </svg>
                </button>
              </div>
              <div class="mt-6 flow-root">
                <div class="divide-gray-500/10 -my-6 divide-y dark:divide-white/10">
                  <div class="space-y-2 py-6">
                    <a
                      href="https://hexdocs.pm/elixir"
                      target="_blank"
                      class="text-base/7 -mx-3 block rounded-lg px-3 py-2 font-semibold text-gray-900 hover:bg-gray-50 dark:text-white dark:hover:bg-white/5"
                    >
                      Elixir
                    </a>
                    <a
                      href="https://hexdocs.pm/phoenix"
                      target="_blank"
                      class="text-base/7 -mx-3 block rounded-lg px-3 py-2 font-semibold text-gray-900 hover:bg-gray-50 dark:text-white dark:hover:bg-white/5"
                    >
                      Phoenix
                    </a>
                    <a
                      href="https://jumar.btkostner.io"
                      target="_blank"
                      class="text-base/7 -mx-3 block rounded-lg px-3 py-2 font-semibold text-gray-900 hover:bg-gray-50 dark:text-white dark:hover:bg-white/5"
                    >
                      Jumar
                    </a>
                  </div>
                  <div class="py-6">
                    <%= if @current_scope.user do %>
                      <.link href={~p"/users/settings"} class="text-base/7 -mx-3 block rounded-lg px-3 py-2.5 font-semibold text-gray-900 hover:bg-gray-50 dark:text-white dark:hover:bg-white/5">
                        Profile
                      </.link>
                      <.link
                        href={~p"/users/log-out"}
                        method="delete"
                        class="text-base/7 -mx-3 block rounded-lg px-3 py-2.5 font-semibold text-gray-900 hover:bg-gray-50 dark:text-white dark:hover:bg-white/5"
                      >
                        Log out
                      </.link>
                    <% else %>
                      <.link href={~p"/users/log-in"} class="text-base/7 -mx-3 block rounded-lg px-3 py-2.5 font-semibold text-gray-900 hover:bg-gray-50 dark:text-white dark:hover:bg-white/5">
                        Log in
                        </.link>
                      <.link href={~p"/users/register"} class="text-base/7 -mx-3 block rounded-lg px-3 py-2.5 font-semibold text-gray-900 hover:bg-gray-50 dark:text-white dark:hover:bg-white/5">
                        Register
                      </.link>
                    <% end %>
                  </div>
                </div>
              </div>
            </el-dialog-panel>
          </div>
        </dialog>
      </el-dialog>
    </header>

    <main class="min-h-dvh flex flex-col md:p-2">
      <div class="grow md:shadow-xs md:ring-zinc-950/5 md:rounded-lg md:bg-white md:ring-1 md:dark:ring-white/10 md:dark:bg-zinc-900">
        <.flash_group flash={@flash} />

        {render_slot(@inner_block)}
      </div>
    </main>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root_layout which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card bg-zinc-950/5 relative flex flex-row items-center rounded-full dark:bg-white/10">
      <div class="[[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left] inset-ring ring-zinc-950/10 inset-ring-white/20 absolute left-0 h-full w-1/3 rounded-full bg-white ring dark:bg-zinc-700 dark:text-white dark:ring-transparent sm:p-0" />

      <button
        class="flex w-1/3 cursor-pointer px-3 py-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="h-4 opacity-70 hover:opacity-100" />
      </button>

      <button
        class="flex w-1/3 cursor-pointer px-3 py-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="h-4 opacity-70 hover:opacity-100" />
      </button>

      <button
        class="flex w-1/3 cursor-pointer px-3 py-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="h-4 opacity-70 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
