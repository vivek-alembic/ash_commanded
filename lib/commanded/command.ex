defmodule AshCommanded.Commanded.Command do
  @moduledoc """
  Struct for representing a Commanded command in the DSL.
  """

  defstruct [:name, :fields, :identity_field]

  @type t :: %__MODULE__{
          name: atom,
          fields: [atom],
          identity_field: atom
        }
end
