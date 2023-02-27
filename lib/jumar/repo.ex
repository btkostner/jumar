defmodule Jumar.Repo do
  use Ecto.Repo,
    otp_app: :jumar,
    adapter: Ecto.Adapters.Postgres
end
