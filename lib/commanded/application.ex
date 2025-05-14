defmodule AshCommanded.Commanded.Application do
  @moduledoc """
  Represents an application configuration in the Commanded DSL.
  
  The application section configures the Commanded application settings including
  the event store adapter, pubsub adapter, and other options.
  """
  
  @type t :: %__MODULE__{
    otp_app: atom(),
    event_store: module(),
    pubsub: module() | nil,
    registry: module() | nil,
    snapshotting: keyword() | nil,
    serializer: module() | nil,
    router_module_name: atom() | nil,
    application_module_name: atom() | nil,
    include_supervisor?: boolean()
  }
  
  defstruct [
    :otp_app,
    :event_store,
    :pubsub,
    :registry,
    :snapshotting,
    :serializer,
    :router_module_name,
    :application_module_name,
    include_supervisor?: true
  ]
end