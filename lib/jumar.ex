defmodule Jumar do
  @moduledoc """
  Jumar keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  use Boundary,
    check: [apps: [:phoenix, :plug]],
    deps: [],
    exports: :all
end
