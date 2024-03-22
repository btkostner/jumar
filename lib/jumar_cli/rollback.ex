defmodule JumarCli.Rollback do
  @moduledoc """
  Rolls back the Jumar database schema to a selected version.
  """

  use Application

  @impl true
  def start(_type, args) do
    {_, [version], _} = OptionParser.parse(args, switches: [version: :string])

    children = [
      Jumar.Repo
    ]

    with {:ok, _pid} <- Supervisor.start_link(children, strategy: :one_for_one) do
      for repo <- repos() do
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
      end
    end

    {:stop, :normal}
  end

  @spec repos() :: [module()]
  defp repos, do: Application.fetch_env!(:jumar, :ecto_repos)
end
