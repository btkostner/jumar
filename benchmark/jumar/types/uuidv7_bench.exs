Benchee.run(
  %{
    "cast uuid" => fn uuid_strings -> Enum.each(uuid_strings, &Ecto.UUID.cast!/1) end,
    "cast uuidv7" => fn uuid_strings -> Enum.each(uuid_strings, &Jumar.Types.UUIDv7.cast!/1) end,
  },
  inputs: %{
    "uuidv4" => Enum.map(1..1000, fn _ -> Ecto.UUID.bingenerate() end),
    "uuidv7" => Enum.map(1..1000, fn _ -> Jumar.Types.UUIDv7.bingenerate() end)
  },
  save: Jumar.Bench.save_opts("types/uuidv7/cast"),
  load: Jumar.Bench.load_opts("types/uuidv7/cast")
)

Benchee.run(
  %{
    "dump uuid" => fn uuid_strings -> Enum.each(uuid_strings, &Ecto.UUID.dump/1) end,
    "dump uuidv7" => fn uuid_strings -> Enum.each(uuid_strings, &Jumar.Types.UUIDv7.dump/1) end,
  },
  inputs: %{
    "uuidv4" => Enum.map(1..1000, fn _ -> Ecto.UUID.generate() end),
    "uuidv7" => Enum.map(1..1000, fn _ -> Jumar.Types.UUIDv7.generate() end)
  },
  save: Jumar.Bench.save_opts("types/uuidv7/dump"),
  load: Jumar.Bench.load_opts("types/uuidv7/dump")
)

Benchee.run(
  %{
    "generate uuid" => fn -> Ecto.UUID.generate() end,
    "generate uuidv7" => fn -> Jumar.Types.UUIDv7.generate() end,
  },
  save: Jumar.Bench.save_opts("types/uuidv7/generate"),
  load: Jumar.Bench.load_opts("types/uuidv7/generate")
)
