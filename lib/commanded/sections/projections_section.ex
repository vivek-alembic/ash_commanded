defmodule AshCommanded.Commanded.Sections.ProjectionsSection do
  @moduledoc false

  def build do
    %Spark.Dsl.Section{
      name: :projections,
      describe: "Projections that handle events and apply changes via Ash actions.",
      schema: [],
      entities: [projection_entity()]
    }
  end

  defp projection_entity do
    %Spark.Dsl.Entity{
      name: :projection,
      describe: "A projection that listens for a specific event and applies changes.",
      target: AshCommanded.Commanded.Projection,
      args: [:event],
      schema: [
        event: [type: :atom, required: true],
        changes: [type: :any, required: true, doc: "Map of changes or function to apply changes from event."],
        action: [type: :atom, required: false, doc: "The Ash action to call (default: :update)."],
        projector_name: [
          type: :atom,
          required: false,
          doc: "Custom module name for the generated projector."
        ],
        autogenerate?: [
          type: :boolean,
          default: true,
          doc: "If false, no module will be generated."
        ]
      ]
    }
  end
end
