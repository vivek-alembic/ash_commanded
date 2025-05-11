defmodule AshCommanded.Commanded.Command do
  @moduledoc """
  Struct for representing a Commanded command in the DSL.
  """

  defstruct [
    :name, 
    :fields, 
    :identity_field, 
    :command_name, 
    :handler_name, 
    autogenerate?: true, 
    autogenerate_handler?: true
  ]

  @type t :: %__MODULE__{
          name: atom,
          fields: [atom],
          identity_field: atom,
          command_name: atom | nil,
          handler_name: atom | nil,
          autogenerate?: boolean,
          autogenerate_handler?: boolean
        }
end
