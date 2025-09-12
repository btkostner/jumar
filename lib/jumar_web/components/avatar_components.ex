defmodule JumarWeb.AvatarComponents do
  @moduledoc """
  Provides avatar components for displaying user profile pictures or initials.
  """

  use Phoenix.Component

  import JumarWeb.ButtonComponents, only: [touch_target: 1]

  @doc """
  Renders an avatar image or initials.

  This component displays a circular or square avatar. It can show an image from a given `src` URL, or display initials if no `src` is provided.

  ## Examples

      <.avatar src="/images/user.png" alt="User avatar" />
      <.avatar initials="BTK" />
      <.avatar src="/images/user.png" square />
  """
  attr :src, :string, default: nil
  attr :square, :boolean, default: false
  attr :initials, :string, default: nil
  attr :alt, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global

  def avatar(assigns) do
    assigns =
      assign(assigns, :class, [
        "inline-grid shrink-0 align-middle [--avatar-radius:20%] *:col-start-1 *:row-start-1",
        "outline -outline-offset-1 outline-black/10 dark:outline-white/10",
        if(
          assigns.square,
          do: "rounded-[--avatar-radius] *:rounded-[--avatar-radius]",
          else: "rounded-full *:rounded-full"
        ),
        assigns.class
      ])

    ~H"""
    <span data-slot="avatar" {@rest} class={@class}>
      <%= if @initials do %>
        <svg
          class="size-full p-[5%] text-[48px] select-none fill-current font-medium uppercase"
          viewBox="0 0 100 100"
          aria-hidden={if @alt == "", do: "true", else: nil}
        >
          <%= if @alt != "" do %>
            <title><%= @alt %></title>
          <% end %>
          <text
            x="50%"
            y="50%"
            alignment-baseline="middle"
            dominant-baseline="middle"
            text-anchor="middle"
            dy=".125em"
          >
            <%= @initials %>
          </text>
        </svg>
      <% end %>
      <%= if @src do %>
        <img class="size-full" src={@src} alt={@alt} />
      <% end %>
    </span>
    """
  end

  @doc """
  Renders a button with an avatar.

  This component can be used as a button or a link, wrapping an avatar. It's useful for profile buttons that open a dropdown menu, for example.

  ## Examples

      <.avatar_button src="/images/user.png" alt="User avatar" />
      <.avatar_button initials="BTK" navigate={~p"/profile"} />
  """
  attr :src, :string, default: nil
  attr :square, :boolean, default: false
  attr :initials, :string, default: nil
  attr :alt, :string, default: ""
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(href navigate patch method)

  def avatar_button(assigns) do
    assigns =
      assign(assigns, :class, [
        "relative inline-grid focus:not-data-focus:outline-hidden data-focus:outline-2 data-focus:outline-offset-2 data-focus:outline-blue-500",
        if(assigns.square, do: "rounded-[20%]", else: "rounded-full"),
        assigns.class
      ])

    ~H"""
    <%= if @rest[:href] || @rest[:navigate] || @rest[:patch] do %>
      <.link
        {@rest}
        class={@class}
      >
        <.touch_target>
          <.avatar src={@src} square={@square} initials={@initials} alt={@alt} />
        </.touch_target>
      </.link>
    <% else %>
      <button
        {@rest}
        class={@class}
      >
        <.touch_target>
          <.avatar src={@src} square={@square} initials={@initials} alt={@alt} />
        </.touch_target>
      </button>
    <% end %>
    """
  end
end
