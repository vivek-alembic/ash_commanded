defmodule AshCommanded.Commanded.Event do
  @moduledoc """
  Struct for representing a Commanded event in the DSL.
  """

  defstruct [:name, :fields]

  @type t :: %__MODULE__{
          name: atom,
          fields: [atom]
        }
end
