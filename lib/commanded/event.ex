defmodule AshCommanded.Commanded.Event do
  @moduledoc """
  Struct for representing a Commanded event in the DSL.
  """

  defstruct [
    :name, 
    :fields, 
    :event_name, 
    autogenerate?: true
  ]

  @type t :: %__MODULE__{
          name: atom,
          fields: [atom],
          event_name: atom | nil,
          autogenerate?: boolean
        }
end
