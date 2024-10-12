defmodule Jumar.ObservabilityTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Jumar.Observability

  describe "report/3" do
    test "grabs current process stacktrace" do
      assert capture_log([metadata: :all], fn ->
               Observability.report("testing")
             end) =~ "observability_test.exs"
    end

    test "logs a binary message" do
      message = "something went wrong"

      assert capture_log(fn ->
               assert Observability.report(message) == :ok
             end) =~ "something went wrong"
    end

    test "logs exception message" do
      exception = ArgumentError.exception("param1 is missing")

      assert capture_log(fn ->
               assert Observability.report(exception) == :ok
             end) =~ "param1 is missing"
    end
  end
end
