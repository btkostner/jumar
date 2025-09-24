defmodule JumarWeb.ModalComponents do
  @moduledoc """
  You'll still get emails from people who accidentally deleted
  their account, but at least you tried.
  """

  use Gettext, backend: JumarWeb.Gettext
  use Phoenix.Component

  import JumarWeb.CoreComponents, only: [icon: 1]

  alias JumarWeb.ButtonComponents
  alias Phoenix.LiveView.JS

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

  @doc """
  Modal dialog component with customizable size and styles.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirmation" on_cancel={JS.navigate(~p"/posts")} on_confirm={JS.push("confirm")}>
        Are you sure you?
        <:confirm>Ok</:confirm>
        <:cancel>Cancel</:concel>
      </.modal>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :size, :string, default: "md", doc: "Size of the modal dialog", values: Map.keys(@sizes)

  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}

  slot :inner_block, required: true
  slot :title
  slot :subtitle
  slot :confirm
  slot :cancel

  def modal(assigns) do
    assigns =
      assigns
      |> assign(:size_classes, @sizes[assigns[:size]])

    ~H"""
    <el-dialog id={@id} phx-on-cancel={@on_cancel} phx-hook=".Modal" open={@show}>
      <dialog autofocus aria-labelledby={@id <> "-title"} class="size-auto max-h-none fixed inset-0 max-w-none overflow-y-auto bg-transparent backdrop:bg-transparent">
        <el-dialog-backdrop class="bg-gray-500/75 fixed inset-0 transition-opacity data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"></el-dialog-backdrop>

        <div tabindex="0" class="flex min-h-full items-center justify-center p-4 text-center focus:outline-none sm:items-center sm:p-0">
          <el-dialog-panel class="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all data-closed:translate-y-4 data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in sm:my-8 sm:w-full sm:max-w-lg sm:data-closed:translate-y-0 sm:data-closed:scale-95">
            <div class="absolute top-6 right-5">
              <button
                phx-click={hide_modal(@on_cancel, @id)}
                type="button"
                class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                aria-label={gettext("close")}
              >
                <.icon name="hero-x-mark-solid" class="h-5 w-5 stroke-current" />
              </button>
            </div>

            <div class="sm:flex sm:items-start">
              <div class="size-12 mx-auto flex shrink-0 items-center justify-center rounded-full bg-red-100 sm:size-10 sm:mx-0">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" data-slot="icon" aria-hidden="true" class="size-6 text-red-600">
                  <path d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z" stroke-linecap="round" stroke-linejoin="round" />
                </svg>
              </div>

              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <h3 :if={@title} id={@id <> "-title"} class="text-base font-semibold text-gray-900">
                  {render_slot(@title)}
                </h3>

                <div :if={@subtitle} class="mt-2">
                  <p class="text-sm text-gray-500">
                    {render_slot(@subtitle)}
                  </p>
                </div>
              </div>
            </div>

            <%= render_slot(@inner_block) %>

            <div
              :if={@confirm != [] or @cancel != []}
              class="flex flex-row-reverse gap-x-4 bg-gray-50 px-4 py-3"
            >
              <ButtonComponents.button
                :for={confirm <- @confirm}
                id={"#{@id}-confirm"}
                phx-click={@on_confirm}
                phx-disable-with
              >
                <%= render_slot(confirm) %>
              </ButtonComponents.button>
              <ButtonComponents.button
                :for={cancel <- @cancel}
                phx-click={hide_modal(@on_cancel, @id)}
                plain
              >
                <%= render_slot(cancel) %>
              </ButtonComponents.button>
            </div>
          </el-dialog-panel>
        </div>
      </dialog>
    </el-dialog>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Modal">
      export default {
        mounted() {
          this.el.addEventListener("close", e => {
            liveSocket.execJS(e.target, e.target.getAttribute("phx-on-cancel"));
          })
        }
      }
    </script>
    """
  end

  @doc """
  Shows an alert dialog with the given `id`.
  """
  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.set_attribute({"open", "true"}, to: "##{id}")
  end

  @doc """
  Hides an alert dialog with the given `id`.
  """
  def hide_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.remove_attribute("open", to: "##{id}")
  end
end
