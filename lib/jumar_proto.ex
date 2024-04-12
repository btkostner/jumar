defmodule JumarProto do
  @moduledoc """
  Jumar utilizes [Protobuf](https://protobuf.dev/) files
  for cross concern communication. This includes api
  endpoints allowing for easy client generation, and message
  queues to allow multiple language support.

  ## Writing Files

  Protobuf files are included in the `priv/protobuf` directory.
  This directory includes a `buf.yaml` configuration that is
  used by buf to download the necessary dependencies.

  ## Generating Files

  To generate files, you'll need the `protoc` compiler installed,
  the Elixir Protobuf plugin installed, and `buf`. Once done, you
  can run this command:

  ```sh
  buf generate
  ```

  Once ran, you'll see a new `lib/jumar_proto` directory that includes
  all of the generated Elixir files.
  """

  use Boundary,
    exports: :all
end
