defmodule AshCommanded.Commanded.Dsl do
  @moduledoc """
  Defines the `:commanded` DSL extension for `Ash.Resource`.
  """

  @sections [
    AshCommanded.Commanded.Sections.CommandsSection.build(),
    AshCommanded.Commanded.Sections.EventsSection.build(),
    AshCommanded.Commanded.Sections.ProjectionsSection.build(),
    AshCommanded.Commanded.Sections.ApplicationSection.build()
  ]

  @transformers [
    AshCommanded.Commanded.Transformers.GenerateCommandModules,
    AshCommanded.Commanded.Transformers.GenerateEventModules,
    AshCommanded.Commanded.Transformers.GenerateProjectionModules,
    AshCommanded.Commanded.Transformers.GenerateAggregateModule,
    AshCommanded.Commanded.Transformers.GenerateDomainRouterModule,
    AshCommanded.Commanded.Transformers.GenerateMainRouterModule,
    AshCommanded.Commanded.Transformers.GenerateCommandedApplication
  ]

  @verifiers [
    AshCommanded.Commanded.Verifiers.ValidateCommandNames,
    AshCommanded.Commanded.Verifiers.ValidateCommandHandlers,
    AshCommanded.Commanded.Verifiers.ValidateCommandActions,
    AshCommanded.Commanded.Verifiers.ValidateCommandFields,
    AshCommanded.Commanded.Verifiers.ValidateCommandNameConflicts,
    AshCommanded.Commanded.Verifiers.ValidateProjectionEvents,
    AshCommanded.Commanded.Verifiers.ValidateProjectionActions,
    AshCommanded.Commanded.Verifiers.ValidateEventNames,
    AshCommanded.Commanded.Verifiers.ValidateEventFields,
    AshCommanded.Commanded.Verifiers.ValidateProjectionChanges
  ]

  use Spark.Dsl.Extension,
    name: :commanded,
    sections: @sections,
    transformers: @transformers,
    verifiers: @verifiers

  defmacro commanded(do: block) do
    quote do
      Spark.Dsl.Extension.do_extend(__MODULE__, unquote(__MODULE__), unquote(block))
    end
  end
end
