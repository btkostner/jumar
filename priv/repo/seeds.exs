# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Jumar.Repo.insert!(%Jumar.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Jumar.Repo.insert!(%Jumar.Accounts.User{
  email: "admin@example.com",
  hashed_password: Argon2.hash_pwd_salt("password"),
  confirmed_at: ~U[2024-01-01 00:00:00Z],
  inserted_at: ~U[2024-01-01 00:00:00Z],
  updated_at: ~U[2024-01-01 00:00:00Z]
})
