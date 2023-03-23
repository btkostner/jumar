defmodule JumarWeb.PageController do
  @moduledoc false

  use JumarWeb, :controller

  @doc false
  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
