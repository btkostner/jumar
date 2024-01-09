defmodule Jumar.Query do
  @moduledoc """
  Additional query macros and functions for Jumar and Cockroach DB.
  """

  @doc """
  Collates a field as case insensitive English. This is to work around
  Cockroach DB not having native support for case insensitive text.

  See this [Cockroach DB issue #22463](https://github.com/cockroachdb/cockroach/issues/22463)
  for more information about the feature and workaround suggested.

  ## Examples

      import Ecto.Query
      import Jumar.Query

      from m in MySchema,
        where: citext(m.name) == "John Doe"

  """
  defmacro citext(something) do
    quote do
      fragment("? COLLATE en_u_ks_level2", unquote(something))
    end
  end
end
