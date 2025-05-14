defmodule AshCommanded.Commanded.Dsl do
  @moduledoc """
  The DSL extension for using Commanded with Ash resources.
  
  This extension provides the ability to define commands, events, and projections using Ash resources,
  and integrates with Commanded to provide CQRS and Event Sourcing patterns.
  
  ## Usage
  
  ```elixir
  defmodule MyApp.User do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]
      
    commanded do
      commands do
        command :register_user do
          fields([:id, :email, :name])
          identity_field(:id)
        end
      end
      
      events do
        event :user_registered do
          fields([:id, :email, :name])
        end
      end
      
      projections do
        projection :user_registered do
          changes(%{status: :active})
        end
      end
    end
  end
  ```
  """

  require Logger
  
  alias AshCommanded.Commanded.Sections.CommandsSection
  
  @commands_section %Spark.Dsl.Section{
    name: :commands,
    describe: "Define commands that trigger state changes in the resource",
    schema: CommandsSection.schema(),
    entities: CommandsSection.entities(),
    imports: []
  }
  
  @events_section %Spark.Dsl.Section{
    name: :events,
    describe: "Define events that are emitted by commands",
    schema: [],
    entities: [],
    imports: []
  }
  
  @projections_section %Spark.Dsl.Section{
    name: :projections,
    describe: "Define how events affect the resource state",
    schema: [],
    entities: [],
    imports: []
  }
  
  @application_section %Spark.Dsl.Section{
    name: :application,
    describe: "Configure Commanded application settings",
    schema: [],
    entities: [],
    imports: []
  }
  
  # Top-level section that contains all other sections
  @commanded_section %Spark.Dsl.Section{
    name: :commanded,
    describe: "Configure CQRS and Event Sourcing with Commanded",
    sections: [
      @commands_section,
      @events_section,
      @projections_section,
      @application_section
    ]
  }
  
  # The main extension
  use Spark.Dsl.Extension,
    sections: [@commanded_section],
    transformers: [],
    verifiers: []

  @doc """
  Determine if a resource uses the `commanded` extension.
  
  ## Examples
  
      iex> AshCommanded.Commanded.Dsl.extension?(SomeResource)
      true
      
      iex> AshCommanded.Commanded.Dsl.extension?(OtherResource)
      false
  """
  @spec extension?(Ash.Resource.t()) :: boolean()
  def extension?(resource) do
    extensions = Spark.extensions(resource)
    __MODULE__ in extensions
  end
end