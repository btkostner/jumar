defmodule JumarCli.Migrate do
  @moduledoc """
  Migrates the Jumar database.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Jumar.Repo
    ]

    with {:ok, _pid} <- Supervisor.start_link(children, strategy: :one_for_one) do
      for repo <- repos() do
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
      end
    end

    {:stop, :normal}
  end

  @spec repos() :: [module()]
  defp repos, do: Application.fetch_env!(:jumar, :ecto_repos)
end
