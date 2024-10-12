defmodule Jumar.Observability do
  @moduledoc """
  Wraps up common observability tools used for Logs, Traces, and Metrics.
  """

  require Logger

  @doc """
  Reports an exception via the logs, traces, and other third party services.

  Emits a `Logger.error` message with correctly formatted metadata. Sets the
  current APM trace to error and attaches the exception. Possibly reports the
  error to third party services like Sentry or Slack via APIs.

  ## Exceptions

  This function works on `Exception` structs. If you pass it in a binary, it
  will create a new `RuntimeError` exception with the binary as the message.

  ## Examples

      # This will report a new RuntimeError with the message of
      # "something went wrong" and a stacktrace.
      def do_something() do
        report("something went wrong")
        :ok
      end

      # This will report the exception and rewrite the message
      # with "something went wrong" but using the stacktrace from
      # this catch block.
      def process_message(message) do
        # do something
      catch
        error ->
          report(error, [message: "something went wrong"], __STACKTRACE__)
          :error
      end

      # This will report the error received from `do_process_event/1`
      # adding event metadata and fetching the stacktrace.
      def process_event(event) do
        with {:error, error} <- do_process_event(event) do
          report(error, event: event)
          {:error, error}
        end
      end

  """
  @spec report(String.t() | Exception.t(), Keyword.t(), Exception.stacktrace()) :: :ok
  def report(message_or_exception, metadata \\ [], stacktrace \\ [])

  def report(message_or_exception, metadata, []) do
    {:current_stacktrace, stacktrace} = Process.info(self(), :current_stacktrace)
    stacktrace = Enum.drop(stacktrace, 2)
    report(message_or_exception, metadata, stacktrace)
  end

  def report(message, metadata, stacktrace) when is_binary(message) do
    message
    |> RuntimeError.exception()
    |> report(metadata, stacktrace)
  end

  def report(exception, metadata, stacktrace) when is_exception(exception) do
    exception_message = Exception.message(exception)
    exception_kind = exception.__struct__ |> Module.split() |> Enum.join(".")
    log_message = Keyword.get(metadata, :message, exception_message)

    full_metadata =
      Keyword.merge(metadata, [
        {OpenTelemetry.SemConv.ExceptionAttributes.exception_message(), exception_message},
        {OpenTelemetry.SemConv.ExceptionAttributes.exception_stacktrace(),
         Exception.format_stacktrace(stacktrace)},
        {OpenTelemetry.SemConv.ExceptionAttributes.exception_type(), exception_kind}
      ])

    Logger.error(log_message, full_metadata)
    :ok
  end
end
