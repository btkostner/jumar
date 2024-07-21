defmodule JumarCli.Rollback do
  @moduledoc """
  Usage: jumar rollback <version>

  Args:

      version        The version to rollback migrations to
  """
  @shortdoc "Rolls back the Jumar database schema"

  use JumarCli.Command

  require Logger

  @impl JumarCli.Command
  def run([version]) do
    children = [
      Jumar.Repo
    ]

    with {:ok, _pid} <- Supervisor.start_link(children, strategy: :one_for_one) do
      for repo <- repos() do
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
      end

      System.halt(0)
    end
  end

  def run(_) do
    {:error, :help_text}
  end

  @spec repos() :: [module()]
  defp repos, do: Application.fetch_env!(:jumar, :ecto_repos)
end
