defmodule JumarCli.Migrate do
  @moduledoc """
  Usage: jumar migrate

  Migrates the Jumar database to the latest version.
  """
  @shortdoc "Migrates the Jumar database"

  use JumarCli.Command

  require Logger

  @impl JumarCli.Command
  def run(_command_line_args) do
    for repo <- repos() do
      # First we ensure the repo is created and accessible.
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &storage_up(&1))

      # Then we have a short wait for the DB to catch up. This
      # prevents an issue we've seen in production with standup and
      # migrations happening too quickly.
      Process.sleep(1_000)

      Supervisor.start_link([repo], strategy: :one_for_one)

      # Finally we run the migrations.
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  defp storage_up(repo) do
    case repo.__adapter__().storage_up(repo.config()) do
      :ok ->
        Logger.info("The database for #{inspect(repo)} has been created")

      {:error, :already_up} ->
        Logger.info("The databse for #{inspect(repo)} has already been created")

      {:error, term} when is_binary(term) ->
        Logger.error("The database for #{inspect(repo)} couldn't be created: #{term}")
        raise RuntimeError, term

      {:error, term} ->
        Logger.error("The database for #{inspect(repo)} couldn't be created: #{inspect(term)}")
        raise RuntimeError, inspect(term)
    end
  end

  @spec repos() :: [module()]
  defp repos, do: Application.fetch_env!(:jumar, :ecto_repos)
end
