defmodule AshCommanded.Commanded.Command do
  @moduledoc """
  Represents a command in the Commanded DSL.
  
  Commands define actions that can be performed on a resource, resulting in events.
  """
  
  @type t :: %__MODULE__{
    name: atom(),
    fields: [atom()],
    identity_field: atom() | nil,
    action: atom() | nil,
    action_type: :create | :update | :destroy | :read | :custom | nil,
    param_mapping: map() | (map() -> map()) | (map(), struct() -> map()) | nil,
    command_name: atom() | nil,
    handler_name: atom() | nil,
    autogenerate_handler?: boolean(),
    middleware: list(module() | {module(), map()}),
    transforms: list(tuple()),
    validations: list(tuple()),
    # Transaction options
    in_transaction?: boolean(),
    repo: atom() | nil,
    transaction_timeout: integer() | nil,
    transaction_isolation_level: :read_committed | :repeatable_read | :serializable | nil
  }
  
  defstruct [
    :name,
    :fields,
    :identity_field,
    :action,
    :action_type,
    :param_mapping,
    :command_name,
    :handler_name,
    autogenerate_handler?: true,
    middleware: [],
    transforms: [],
    validations: [],
    # Transaction options
    in_transaction?: false,
    repo: nil,
    transaction_timeout: nil,
    transaction_isolation_level: nil
  ]
end