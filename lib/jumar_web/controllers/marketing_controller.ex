defmodule JumarWeb.MarketingController do
  @moduledoc false

  use JumarWeb, :controller

  @doc false
  def home(conn, _params) do
    render(conn, :home)
  end
end
