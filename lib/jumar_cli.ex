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
    {"iex", "Starts an interactive Elixir shell for Jumar"},
    {"remote", "Attach to an already running local Jumar instance"}
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
    "JUMAR_CMD"
    |> System.get_env("")
    |> run()
  end

  @doc """
  Runs a Jumar CLI command.

  ## Examples

      iex> JumarCli.run("migrate")
      :ok

  """
  @spec run(String.t() | Command.args()) :: Command.return_value()
  def run(args) when is_binary(args) do
    args
    |> String.split(" ")
    |> run()
  end

  # If nothing is specified, we run the application
  # command which includes _everything_. This allows us to
  # specify this module as the Elixir application in `mix.exs`,
  # and have tests and other Elixir code start the application
  # as expected.
  def run([""]) do
    JumarCli.Application.run("")
  end

  # If any arguments are passed in, we then use the OptionParser
  # to make a more "native" feeling CLI that can parse flags and
  # run subcommands.
  def run(args) do
    {options, rest, _} = OptionParser.parse(args, @options)

    subcommand = Enum.at(rest, 0, "")
    args = Enum.drop(rest, 1)

    command_mod = Enum.find(@commands, __MODULE__, fn c ->
      Command.command_name(c) == subcommand
    end)

    case run(command_mod, args, options) do
      :ok ->
        :ok

      {:ok, pid} ->
        {:ok, pid}

      {:error, :help_text} ->
        help_text = Command.moduledoc(command_mod)
        IO.puts(help_text)
        :stop

      {:error, message} ->
        IO.puts("Error: #{message}")
        :stop
    end
  end

  @spec run(Command.mod() | nil, Command.args(), map()) :: Command.return_value()
  defp run(command_mod, args, opts)

  # The most basic run command involves using `--version` or `-v`
  # which will _always_ print out the current application version.
  defp run(_command_mod, _args, %{version: true}) do
    IO.puts("Jumar #{Application.spec(:jumar, :vsn)}")
  end

  # The second most basic run command is `--help` or `-h` which
  # will print out the help text for the given command if invoked
  # with a subcommand like `seed --help`, or the main help text
  # if ran without a subcommand.
  defp run(command_mod, _args, %{help: true}) do
    command_mod
    |> Command.moduledoc()
    |> IO.puts()
  end

  # And finally, the actual command running. If the command is matched
  # to a known subcommand, run it.  Otherwise we print out an error
  # and help text.
  defp run(__MODULE__, _args, _opts) do
    IO.puts("Unknown command.")
    IO.puts("")
    {:error, :help_text}
  end

  defp run(command_mod, args, _opts) do
    command_mod.run(args)
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
