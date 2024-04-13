defmodule JumarCli do
  @moduledoc """
  The JumarCli module contains custom commands that are
  used by `mix release` and the generated Docker file. This
  allows us to use the Elixir `OptionParser` for a more
  advanced CLI interface.
  """

  use Application

  use Boundary,
    deps: [Jumar, JumarWeb],
    exports: []

  @impl true
  def start(type, _args) do
    # Instead of pulling the args from CLI, we pull them from
    # an environment variable. This is set in the `rel/overlays/bin/jumar`
    # shell script. This provides some more flexability with
    # how the BEAM vm is started.
    args = "JUMAR_CMD" |> System.get_env("") |> String.split(" ")

    # We use the OptionParser to make a more "native" feeling
    # CLI that can parse flags and values.
    {options, rest, _} =
      OptionParser.parse_head(args,
        aliases: [
          h: :help,
          v: :version
        ],
        switches: [
          help: :boolean,
          version: :boolean
        ]
      )

    # We split up the command text for easier pattern matching
    # and passing in the remainder to sub commands.
    command = Enum.at(rest, 0, "")
    args = Enum.drop(rest, 1)

    case {command, Enum.into(options, %{})} do
      # Root level args to mirror how most CLI applications work.
      {_, %{help: true}} ->
        IO.puts(help_text())
        System.halt(0)

      {_, %{version: true}} ->
        IO.puts("Jumar #{Application.spec(:jumar, :vsn)}")
        System.halt(0)

      # Runs database related tasks.
      {"migrate", _} ->
        JumarCli.Migrate.start(type, args)

      {"rollback", _} ->
        JumarCli.Rollback.start(type, args)

      {"seed", _} ->
        JumarCli.Seed.start(type, args)

      # Starts the web server without any other cruft like
      # event processing. This allows us to split up our "frontend"
      # customer facing servers from our "backend" async processing
      # servers.
      {"server", _} ->
        JumarCli.Server.start(type, args)

      # If nothing is given as an arg, we run the application
      # module which includes _everything_. This allows us to
      # specify this module as the Elixir application in `mix.exs`,
      # and have tests and other Elixir code start the application
      # as expected.
      {"", _} ->
        JumarCli.Application.start(type, args)

      # For everything else, we help and exit.
      _ ->
        IO.puts("Unknown command: #{System.get_env("JUMAR_CMD")}")
        IO.puts("")
        IO.puts(help_text())
        System.halt(1)
    end
  end

  @doc """
  Returns help text for Jumar CLI. This is returned when doing
  `--help` or `-h`. Note that this help text includes some
  commands that are setup in the jumar shell script outside of Elixir.
  """
  def help_text() do
    """
    Usage: jumar [options] command [args]

    Options:
        -h, --help     Prints this help text
        -v, --version  Prints the Jumar version

    Commands:

        iex            Starts an interactive Elixir shell for Jumar
        migrate        Runs the database migrations
        rollback       Rolls back the database to a specified migration
        seed           Adds dummy data to the database
        server         Starts the web server
    """
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JumarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
