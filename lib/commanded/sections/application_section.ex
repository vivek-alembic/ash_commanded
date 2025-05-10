defmodule AshCommanded.Commanded.Sections.ApplicationSection do
  @moduledoc false

  def build do
    %Spark.Dsl.Section{
      name: :application,
      describe: "Configuration for the Commanded application.",
      schema: [
        otp_app: [
          type: :atom,
          required: false,
          doc: "The OTP application name. Defaults to :ash_commanded if not provided."
        ],
        name: [
          type: :atom,
          required: false,
          doc: "The name of the generated application module. Defaults to {DomainName}CommandedApp."
        ],
        event_store: [
          type: {:one_of, [:module, :atom]},
          required: false,
          doc: "Event store adapter to use. Defaults to EventStore.Adapters.InMemory."
        ],
        pubsub: [
          type: :module,
          required: false,
          doc: "PubSub adapter to use for broadcasting events."
        ],
        registry: [
          type: {:one_of, [:atom, {:tuple, [:atom, :atom, :atom]}]},
          required: false,
          doc: "Process registry. Defaults to Commanded.Registration.SwarmRegistry."
        ],
        snapshotting: [
          type: :boolean,
          default: false,
          doc: "Whether to use snapshotting for aggregates."
        ],
        snapshot_every: [
          type: :integer,
          required: false,
          doc: "Take a snapshot every number of events. Requires snapshotting to be enabled."
        ],
        snapshot_version: [
          type: :integer,
          required: false,
          doc: "Snapshot version, use to upgrade snapshots."
        ],
        registered_name: [
          type: :atom,
          required: false,
          doc: "Register the application process with the given name."
        ],
        include_supervisor?: [
          type: :boolean,
          default: true,
          doc: "Whether to include a supervisor for all projectors. Default is true."
        ],
        include_application_module?: [
          type: :boolean,
          default: true,
          doc: "Whether to generate an application module. Default is true."
        ]
      ]
    }
  end
end