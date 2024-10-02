defmodule Jumar.Bench do
  @moduledoc """
  Helper utilties for benchmarking Jumar functions.
  """

  @benchmark_results Path.join(__DIR__, "../../benchmark_results")

  @doc """
  Returns benchee options for saving the benchmark results
  to a file. This is used in conjunction with `load_opts/1`
  will allows you to load previous benchmark results for comparing.
  """
  @spec save_opts(String.t()) :: Keyword.t()
  def save_opts(name) do
    [
      path: Path.join([@benchmark_results, slug(name), git_tag()]),
      tag: git_tag()
    ]
  end

  @doc """
  Returns benchee options to load previously ran benchmark
  results.
  """
  @spec load_opts(String.t()) :: [String.t()]
  def load_opts(name) do
    @benchmark_results
    |> Path.join(slug(name))
    |> Path.join("*")
    |> Path.wildcard()
  end

  @spec slug(String.t()) :: String.t()
  defp slug(string) do
    string
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
    |> String.replace("/", "-")
    |> String.replace(~r/[^\w\-]+/, "")
    |> String.replace(~r/\-\-+/, "-")
    |> String.trim("-")
  end

  @spec git_tag() :: String.t()
  defp git_tag do
    case __DIR__ |> Path.join("../../.git/HEAD") |> File.read() do
      {:ok, tag} ->
        tag
        |> String.trim_leading("ref:")
        |> String.trim()
        |> slug()

      _ -> "local"
    end
  end
end
