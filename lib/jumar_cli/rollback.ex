defmodule JumarCli.Rollback do
  @moduledoc """
  Rolls back the Jumar database schema to a selected version.
  """

  use Application

  @impl true
  def start(_type, args) do
    {options, rest, _} =
      OptionParser.parse(args,
        aliases: [
          h: :help
        ],
        switches: [
          help: :boolean
        ]
      )

    if Keyword.get(options, :help, false) do
      IO.puts(help_text())
      System.halt(0)
    end

    if rest == [] do
      IO.puts("rollback requires a version")
      IO.puts("")
      IO.puts(help_text())
      System.halt(1)
    end

    children = [
      Jumar.Repo
    ]

    [version] = rest

    with {:ok, _pid} <- Supervisor.start_link(children, strategy: :one_for_one) do
      for repo <- repos() do
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
      end

      System.halt(0)
    end
  end

  @doc """
  Returns the help text for rollbacks.
  """
  def help_text() do
    """
    Usage: jumar rollback <version> [args]

    Args:
        version        The version to rollback migrations to

    Options:
        -h, --help     Prints this help text
    """
  end

  @spec repos() :: [module()]
  defp repos, do: Application.fetch_env!(:jumar, :ecto_repos)
end
