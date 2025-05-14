defmodule AshCommanded.Commanded.Sections.ApplicationSection do
  @moduledoc """
  Defines the schema and entities for the `application` section of the Commanded DSL.
  
  The application section configures how the Commanded application is set up and configured.
  """
  
  def schema do
    [
      otp_app: [
        type: :atom,
        required: true,
        doc: "The OTP application name that will be used for configuration"
      ],
      event_store: [
        type: :module,
        required: true,
        doc: "The event store adapter to use (e.g., Commanded.EventStore.Adapters.InMemory)"
      ],
      pubsub: [
        type: :module,
        doc: "The pubsub adapter to use for distributing events"
      ],
      registry: [
        type: :module,
        doc: "The registry adapter to use for process registration"
      ],
      snapshotting: [
        type: :keyword_list,
        doc: "Snapshotting configuration for the application"
      ],
      serializer: [
        type: :module,
        doc: "The serializer to use for event serialization"
      ],
      router_module_name: [
        type: :atom,
        doc: "Override the auto-generated router module name"
      ],
      application_module_name: [
        type: :atom,
        doc: "Override the auto-generated application module name"
      ],
      include_supervisor?: [
        type: :boolean,
        default: true,
        doc: "Whether to include a supervisor for the projectors"
      ]
    ]
  end
  
  def entities do
    []
  end
end