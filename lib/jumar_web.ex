defmodule JumarWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use JumarWeb, :controller
      use JumarWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  @doc """
  Returns a list of folders and files in the `priv/static` directory
  that should be served publicly.
  """
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  @doc """
  Returns a list of router helpers.
  """
  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  @doc """
  Returns `Phoenix.Channel` helpers.
  """
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  @doc """
  Returns controller helpers.
  """
  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: JumarWeb.Layouts]

      import Plug.Conn
      import JumarWeb.Gettext

      unquote(verified_routes())
    end
  end

  @doc """
  Returns `Phoenix.LiveView` helpers.
  """
  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {JumarWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  @doc """
  Returns `Phoenix.LiveComponent` helpers.
  """
  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  @doc """
  Returns a list of useful helpers when creating HTML templates.
  """
  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import JumarWeb.CoreComponents
      import JumarWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  @doc """
  Adds verified route compile logic to the module.
  """
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: JumarWeb.Endpoint,
        router: JumarWeb.Router,
        statics: JumarWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
