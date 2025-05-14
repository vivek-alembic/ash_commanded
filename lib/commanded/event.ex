defmodule AshCommanded.Commanded.Event do
  @moduledoc """
  Represents an event in the Commanded DSL.
  
  Events represent facts that have occurred in the system and are emitted by commands.
  """
  
  @type t :: %__MODULE__{
    name: atom(),
    fields: [atom()],
    event_name: atom() | nil
  }
  
  defstruct [
    :name,
    :fields,
    :event_name
  ]
end