defmodule JumarCli.Seed do
  @moduledoc """
  Adds dummy data to the database. This can be used for
  testing other services, or even just setting up a demo
  environment to play with.
  """

  use Application

  require Logger

  @impl true
  def start(_type, args) do
    {options, _, _} =
      OptionParser.parse(args,
        aliases: [
          h: :help,
          f: :force
        ],
        switches: [
          help: :boolean,
          force: :boolean
        ]
      )

    if Keyword.get(options, :help, false) do
      IO.puts(help_text())
      System.halt(0)
    end

    children = [
      Jumar.Repo
    ]

    with {:ok, _pid} <- Supervisor.start_link(children, strategy: :one_for_one) do
      for repo <- repos() do
        # We want to check if the database has any data in it yet.
        # If it does, we prevent running seeds unless it's forced.
        # This is to prevent accidental data loss from running this
        # command in a production environment.
        has_data? = has_data?(repo)

        if has_data? and not Keyword.get(options, :force, false) do
          IO.puts("Databases already have data. Use --force to seed anyway.")
          System.halt(1)
        end

        # Our seed data does not take into consideration any other
        # data existing in the database. We first need to reset everything
        # to ensure we are starting from a clean slate.
        if has_data? and Keyword.get(options, :force, false) do
          for {schema, table} <- tables_in(repo) do
            truncate!(repo, schema, table)
          end
        end

        # Now we can finally run the seed script for the repo.
        {:ok, _, _} =
          Ecto.Migrator.with_repo(repo, fn repo ->
            priv_dir = "#{:code.priv_dir(:jumar)}"

            repo_underscore =
              repo
              |> Module.split()
              |> List.last()
              |> Macro.underscore()

            seeds_file = Path.join([priv_dir, repo_underscore, "seeds.exs"])

            if File.regular?(seeds_file) do
              Code.eval_file(seeds_file)
            end
          end)
      end

      System.halt(0)
    end
  end

  @doc """
  Returns the help text for migrations.
  """
  def help_text() do
    """
    Usage: jumar seed [args]

    Options:
        -h, --help     Prints this help text
        -f, --force    Forces seeding the database by resetting it first
    """
  end

  @spec tables_in(module) :: [{String.t(), String.t()}]
  defp tables_in(repo) do
    %{rows: rows} = Ecto.Adapters.SQL.query!(repo, "SHOW TABLES")

    rows
    |> Enum.reject(fn [_, table, _, _, _, _] -> table == "schema_migrations" end)
    |> Enum.map(fn [schema, table, _, _, _, _] -> {schema, table} end)
  end

  @spec has_data?(module()) :: boolean()
  defp has_data?(repo) do
    Enum.any?(tables_in(repo), fn {schema, table} ->
      has_data?(repo, schema, table)
    end)
  end

  @spec has_data?(module(), String.t(), String.t()) :: boolean()
  defp has_data?(repo, schema, table) do
    case Ecto.Adapters.SQL.query(repo, "SELECT * FROM #{schema}.#{table} LIMIT 1") do
      {:ok, %{rows: []}} ->
        false

      {:ok, %{rows: _rows}} ->
        true

      # We return true on failure to ensure we don't accidently delete
      # data in case of an error.
      other ->
        Logger.warning("Unexpected result fetching table rows: #{inspect(other)}")
        true
    end
  end

  defp truncate!(repo, schema, table) do
    Ecto.Adapters.SQL.query!(repo, "TRUNCATE TABLE #{schema}.#{table} CASCADE")
  end

  @spec repos() :: [module()]
  defp repos, do: Application.fetch_env!(:jumar, :ecto_repos)
end
