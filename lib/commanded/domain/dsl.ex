defmodule AshCommanded.Commanded.Domain.Dsl do
  @moduledoc """
  The DSL extension for using Commanded with Ash domains.
  
  This extension provides domain-level configuration for Commanded, including application settings.
  
  ## Usage
  
  ```elixir
  defmodule MyApp.Domain do
    use Ash.Domain,
      extensions: [AshCommanded.Commanded.Domain.Dsl]
      
    commanded do
      application do
        otp_app :my_app
        event_store Commanded.EventStore.Adapters.InMemory
        include_supervisor? true
      end
    end
  end
  ```
  """

  require Logger
  
  alias AshCommanded.Commanded.Sections.ApplicationSection
  
  @application_section %Spark.Dsl.Section{
    name: :application,
    describe: "Configure Commanded application settings",
    schema: ApplicationSection.schema(),
    entities: ApplicationSection.entities(),
    imports: []
  }
  
  # Top-level section for domains
  @commanded_section %Spark.Dsl.Section{
    name: :commanded,
    describe: "Configure CQRS and Event Sourcing with Commanded at the domain level",
    sections: [
      @application_section
    ]
  }
  
  # The main extension
  use Spark.Dsl.Extension,
    sections: [@commanded_section],
    transformers: [],
    verifiers: []

  @doc """
  Determine if a domain uses the `commanded` extension.
  
  ## Examples
  
      iex> AshCommanded.Commanded.Domain.Dsl.extension?(SomeDomain)
      true
      
      iex> AshCommanded.Commanded.Domain.Dsl.extension?(OtherDomain)
      false
  """
  @spec extension?(Ash.Domain.t()) :: boolean()
  def extension?(domain) do
    Spark.implements_behaviour?(domain, Ash.Domain) &&
      __MODULE__ in Spark.extensions(domain)
  end
end