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

  alias JumarCli.Command

  @commands [
    JumarCli.Migrate,
    JumarCli.Rollback,
    JumarCli.Seed,
    JumarCli.Server
  ]

  @elixir_commands [
    {"iex", "Starts an interactive Elixir shell for Jumar"}
  ]

  @options [
    aliases: [
      h: :help,
      v: :version
    ],
    switches: [
      help: :boolean,
      version: :boolean
    ]
  ]

  @impl Application
  def start(_type, _args) do
    # The easiest way to pass in command line args into an
    # application on the Beam VM is with environment variables.
    # This is set in `rel/overlays/bin/jumar`.
    args = "JUMAR_CMD" |> System.get_env("") |> String.split(" ")

    # We use the OptionParser to make a more "native" feeling
    # CLI that can parse flags and values.
    {options, rest, _} = OptionParser.parse(args, @options)

    # We split up the command text for easier pattern matching
    # and passing in the remainder to sub commands.
    command = Enum.at(rest, 0, "")
    args = Enum.drop(rest, 1)

    case {command, Enum.into(options, %{})} do
      # Root level args to mirror how most CLI applications work.
      {subcommand, %{help: true}} ->
        found_command =
          Enum.find(@commands, fn command ->
            Command.command_name(command) == subcommand
          end)

        if is_nil(found_command) do
          IO.puts(Command.moduledoc(__MODULE__))
          System.halt(0)
        else
          IO.puts(Command.moduledoc(found_command))
          System.halt(0)
        end

      {_, %{version: true}} ->
        IO.puts("Jumar #{Application.spec(:jumar, :vsn)}")
        System.halt(0)

      # If nothing is given as a subcommand, we run the application
      # command which includes _everything_. This allows us to
      # specify this module as the Elixir application in `mix.exs`,
      # and have tests and other Elixir code start the application
      # as expected.
      {"", _} ->
        JumarCli.Application.run("")

      # For everything else, we help and exit.
      {subcommand, _} ->
        found_command =
          Enum.find(@commands, fn command ->
            Command.command_name(command) == subcommand
          end)

        if is_nil(found_command) do
          IO.puts("Unknown command: #{subcommand}")
          IO.puts("")
          IO.puts(Command.moduledoc(__MODULE__))
          System.halt(1)
        end

        case found_command.run(args) do
          {:ok, nil} ->
            System.halt(0)

          {:ok, pid} ->
            {:ok, pid}

          {:error, :help_text} ->
            IO.puts(Command.moduledoc(command))
            System.halt(1)

          {:error, message} ->
            IO.puts("Error: #{message}")
            System.halt(1)
        end
    end
  end

  @doc """
  Returns help text for Jumar CLI. This is returned when doing
  `--help` or `-h`. Note that this help text includes some
  commands that are setup in the jumar shell script outside of Elixir.
  """
  def moduledoc() do
    command_text =
      @commands
      |> Enum.map(fn c -> {Command.command_name(c), Command.shortdoc(c)} end)
      |> Enum.concat(@elixir_commands)
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map(fn {name, doc} ->
        String.pad_trailing(name, 15) <> doc
      end)
      |> Enum.join("\n    ")

    """
    Usage: jumar [options] command [args]

    Options:

        -h, --help     Prints this help text
        -v, --version  Prints the Jumar version

    Commands:

        #{command_text}
    """
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    JumarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
