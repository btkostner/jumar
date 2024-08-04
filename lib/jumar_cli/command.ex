defmodule JumarCli.Command do
  @moduledoc """
  A module for CLI commands and subcommands that can
  be executed by the Jumar CLI. This follows a very
  similar pattern to `Mix.Task` in Elixir, but is used
  for the released application CLI in Jumar Docker.
  """

  @typedoc "The name of the command. This is the name used in the CLI."
  @type name :: String.t()

  @typedoc "Any module that implements the `JumarCli.Command` behaviour."
  @type mod :: module()

  @typedoc "A list of command line arguments passed to the command."
  @type args :: [String.t()]

  @typedoc """
  Commands can return different values depending on
  what the command does. They can return:

  - `{:ok, nil}` which will exit the CLI with a status
    code of 0.

  - `{:ok, pid()}` which monitor the pid as the main
    process of the CLI. This can be used for starting
    a web server or other long running processes.

  - `{:error, :help_text}` which will print the help
    text for the command and exit the CLI with a status
    code of 1.

  - `{:error, any()}` which will print the error message
    and exit the CLI with a status code of 1.
  """
  @type return_value :: :ok | {:ok, pid()} | {:error, :help_text} | {:error, any()}

  @doc """
  This is the command actual ran by the CLI.
  """
  @callback run(args) :: return_value

  @doc false
  defmacro __using__(_opts) do
    quote do
      Enum.each(
        [:shortdoc],
        &Module.register_attribute(__MODULE__, &1, persist: true)
      )

      @behaviour JumarCli.Command
    end
  end

  @doc """
  Gets the moduledoc for the given command `module`.

  Returns the moduledoc or `nil`.
  """
  @spec moduledoc(mod) :: String.t()
  def moduledoc(module) when is_atom(module) do
    if function_exported?(module, :moduledoc, 0) do
      module.moduledoc()
    else
      case Code.fetch_docs(module) do
        {:docs_v1, _, _, _, %{"en" => moduledoc}, _, _} -> moduledoc
        {:docs_v1, _, _, _, :none, _, _} -> ""
        _ -> ""
      end
    end
  end

  @doc """
  Gets the shortdoc for the given command `module`.

  Returns the shortdoc or `nil`.
  """
  @spec shortdoc(mod) :: String.t()
  def shortdoc(module) when is_atom(module) do
    if function_exported?(module, :shortdoc, 0) do
      module.shortdoc()
    else
      case List.keyfind(module.__info__(:attributes), :shortdoc, 0) do
        {:shortdoc, [shortdoc]} -> shortdoc
        _ -> ""
      end
    end
  end

  @doc """
  Returns the command name for the given `module`.

  ## Examples

      iex> JumarCli.Command.command_name(JumarCli.Commands.Migrate)
      "migrate"

  """
  @spec command_name(mod) :: name
  def command_name(module) when is_atom(module) do
    module
    |> to_string()
    |> String.split(".")
    |> Enum.drop(2)
    |> Enum.map_join(" ", &Macro.underscore/1)
  end
end
