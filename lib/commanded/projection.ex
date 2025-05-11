defmodule AshCommanded.Commanded.Projection do
  @moduledoc """
  Struct for representing a projection update in response to an event.
  """

  defstruct [
    :event, 
    :changes, 
    :action, 
    :projector_name, 
    autogenerate?: true
  ]

  @type t :: %__MODULE__{
          event: atom,
          changes: %{optional(atom) => any} | (any -> %{optional(atom) => any}),
          action: atom | nil,
          projector_name: atom | nil,
          autogenerate?: boolean
        }
end
