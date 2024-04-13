defmodule JumarCli.Migrate do
  @moduledoc """
  Migrates the Jumar database.
  """

  use Application

  require Logger

  @impl true
  def start(_type, args) do
    {options, _, _} =
      OptionParser.parse(args,
        aliases: [
          h: :help,
          v: :version
        ],
        switches: [
          help: :boolean,
          version: :string
        ]
      )

    if Keyword.get(options, :help, false) do
      IO.puts(help_text())
      System.halt(0)
    end

    children = [
      Jumar.Repo
    ]

    migrate_options =
      if version = Keyword.get(options, :version),
        do: [to: version],
        else: [all: true]

    with {:ok, _pid} <- Supervisor.start_link(children, strategy: :one_for_one) do
      for repo <- repos() do
        {:ok, _, _} =
          Ecto.Migrator.with_repo(repo, fn repo ->
            case repo.__adapter__.storage_up(repo.config) do
              :ok ->
                Logger.info("The database for #{inspect(repo)} has been created")

              {:error, :already_up} ->
                Logger.info("The databse for #{inspect(repo)} has already been created")

              {:error, term} when is_binary(term) ->
                Logger.error("The database for #{inspect(repo)} couldn't be created: #{term}")

              {:error, term} ->
                Logger.error(
                  "The database for #{inspect(repo)} couldn't be created: #{inspect(term)}"
                )
            end
          end)

        # We have ran into issues where the database is not
        # yet ready to migrate. So we wait.
        Process.sleep(1_000)

        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, migrate_options))
      end

      System.halt(0)
    end
  end

  @doc """
  Returns the help text for migrations.
  """
  def help_text() do
    """
    Usage: jumar migrate [args]

    Options:
        -h, --help     Prints this help text
        -v, --version  The version to migrate to. Defaults to latest
    """
  end

  @spec repos() :: [module()]
  defp repos, do: Application.fetch_env!(:jumar, :ecto_repos)
end
