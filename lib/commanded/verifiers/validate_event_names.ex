defmodule AshCommanded.Commanded.Verifiers.ValidateEventNames do
  @moduledoc """
  Ensures that all event names are unique within a resource.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    names =
      Info.events(resource)
      |> Enum.map(& &1.name)

    duplicates = names -- Enum.uniq(names)

    if duplicates != [] do
      raise DslError,
        path: [:commanded, :events],
        message: "Duplicate event names detected: #{inspect(Enum.uniq(duplicates))}"
    end

    :ok
  end
end
