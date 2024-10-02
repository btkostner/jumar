defmodule Jumar.EventBus.Event do
  @moduledoc """
  An event with data and metadata passed between contexts.
  """

  defstruct [:name, :data, metadata: []]

  @typedoc """
  An event passed between contexts.
  """
  @type t :: %__MODULE__{
          name: atom(),
          data: map(),
          metadata: [{atom(), any()}]
        }
end
