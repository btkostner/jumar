defmodule Jumar.Repo do
  @moduledoc """
  The main Cockroach DB `Ecto.Repo` instance for the application.
  """

  use Ecto.Repo,
    otp_app: :jumar,
    adapter: Ecto.Adapters.Postgres
end
