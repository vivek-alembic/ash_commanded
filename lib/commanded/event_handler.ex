defmodule AshCommanded.Commanded.EventHandler do
  @moduledoc """
  Represents a general purpose event handler in the Commanded DSL.
  
  Event handlers respond to specific events with custom logic that can
  perform side effects, interact with external systems, or trigger
  other actions that don't necessarily update the resource state.
  """
  
  defstruct [
    :name,
    :events,
    :handler_name,
    :action,
    :publish_to,
    idempotent: false,
    autogenerate?: true
  ]
  
  @type t :: %__MODULE__{
    name: atom(),
    events: [atom()],
    handler_name: atom() | nil,
    action: atom() | Macro.t() | nil,
    publish_to: atom() | String.t() | [atom() | String.t()] | nil,
    idempotent: boolean(),
    autogenerate?: boolean()
  }
end