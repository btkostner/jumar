# A lazy wrapper for benchee files to match how exunit works
# Run with `mix benchmark`

"benchmark/**/*_bench.exs"
|> Path.wildcard()
|> Enum.sort()
|> Enum.each(&Code.require_file/1)
