defmodule AshCommanded.Commanded.Projection do
  @moduledoc """
  Struct for representing a projection update in response to an event.
  """

  defstruct [:event, :changes]

  @type t :: %__MODULE__{
          event: atom,
          changes: %{optional(atom) => atom}
        }
end
