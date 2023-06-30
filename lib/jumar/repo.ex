defmodule Jumar.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :jumar,
    adapter: Ecto.Adapters.Postgres
end
