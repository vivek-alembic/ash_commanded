defmodule AshCommanded.Commanded.Sections.EventsSection do
  @moduledoc false

  def build do
    %Spark.Dsl.Section{
      name: :events,
      describe: "Events that may be applied and projected by the aggregate.",
      schema: [],
      entities: [event_entity()]
    }
  end

  defp event_entity do
    %Spark.Dsl.Entity{
      name: :event,
      describe: "An event struct definition for the aggregate.",
      target: AshCommanded.Commanded.Event,
      args: [:name],
      schema: [
        name: [type: :atom, required: true],
        fields: [type: {:list, :atom}, required: true],
        event_name: [type: :atom, required: false, doc: "Custom name for the generated module."],
        autogenerate?: [
          type: :boolean,
          default: true,
          doc: "If false, the event module won't be generated."
        ]
      ]
    }
  end
end
