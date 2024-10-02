defmodule JumarCliTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  describe "run/1" do
    test "shows help text when --help specified" do
      output = capture_io(fn -> JumarCli.run("--help") end)
      assert output =~ "Usage: jumar [options] command [args]"
    end

    test "shows subcommand help text when --help specified" do
      output = capture_io(fn -> JumarCli.run("migrate --help") end)
      assert output =~ "Usage: jumar migrate"
    end

    test "shows version when --version specified" do
      output = capture_io(fn -> JumarCli.run("--version") end)
      assert output =~ "Jumar #{Application.spec(:jumar, :vsn)}"
    end
  end

  describe "moduledoc/0" do
    test "lists all commands available" do
      moduledoc = JumarCli.moduledoc()

      assert moduledoc =~ "iex"
      assert moduledoc =~ "migrate"
      assert moduledoc =~ "remote"
      assert moduledoc =~ "seed"
    end
  end
end
