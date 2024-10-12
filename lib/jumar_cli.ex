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

  @dialyzer {:no_return, {:start, 2}}

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
    response_code =
      "JUMAR_CMD"
      |> System.get_env("")
      |> run()

    case response_code do
      {:ok, code} when is_integer(code) ->
        # If we were given an exit code, we still need to return
        # a pid for the application to start with. This ensures we
        # don't get a crash or random error codes during startup.
        app_fun = fn ->
          Process.sleep(10)
          System.halt(code)
        end

        {:ok, spawn(app_fun)}

      {:ok, pid} when is_pid(pid) ->
        {:ok, pid}
    end
  end

  @doc """
  Runs a Jumar CLI command. Will always return an ok tuple
  with either a pid for a long running process, or a non
  negative integer for a cli exit code.

  ## Examples

      iex> JumarCli.run("migrate")
      {:ok, 0}

  """
  @spec run(String.t() | Command.args()) :: {:ok, non_neg_integer()} | {:ok, pid()}
  def run(args) when is_binary(args) do
    args
    |> String.split(" ")
    |> Enum.filter(&(&1 != ""))
    |> run()
  end

  # If nothing is specified, we run the application
  # command which includes _everything_. This allows us to
  # specify this module as the Elixir application in `mix.exs`,
  # and have tests and other Elixir code start the application
  # as expected.
  def run([]) do
    JumarCli.Application.run([])
  end

  # If any arguments are passed in, we then use the OptionParser
  # to make a more "native" feeling CLI that can parse flags and
  # run subcommands.
  def run(args) when is_list(args) do
    {_, rest, _} = OptionParser.parse_head(args, @options)
    {options, _, _} = OptionParser.parse(args, @options)

    subcommand = Enum.at(rest, 0, "")
    args = Enum.drop(rest, 1)
    options = Enum.into(options, %{})

    command_mod =
      Enum.find(@commands, __MODULE__, fn c ->
        Command.command_name(c) == subcommand
      end)

    case run(command_mod, args, options) do
      :ok ->
        {:ok, 0}

      {:ok, pid} ->
        {:ok, pid}

      {:error, :help_text} ->
        help_text = Command.moduledoc(command_mod)
        IO.puts(help_text)
        {:ok, 1}

      {:error, message} ->
        IO.puts("Error: #{message}")
        {:ok, 1}
    end
  end

  @spec run(Command.mod(), Command.args(), map()) :: Command.return_value()
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
  def moduledoc do
    command_text =
      @commands
      |> Enum.map(fn c -> {Command.command_name(c), Command.shortdoc(c)} end)
      |> Enum.concat(@elixir_commands)
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map_join("\n    ", fn {name, doc} ->
        String.pad_trailing(name, 15) <> doc
      end)

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
