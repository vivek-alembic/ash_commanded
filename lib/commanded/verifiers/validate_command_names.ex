defmodule AshCommanded.Commanded.Verifiers.ValidateCommandNames do
  @moduledoc """
  Ensures that each command name within a resource is unique.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    names =
      Info.commands(resource)
      |> Enum.map(& &1.name)

    duplicates = names -- Enum.uniq(names)

    if duplicates != [] do
      raise DslError,
        path: [:commanded, :commands],
        message: "Duplicate command names detected: #{inspect(Enum.uniq(duplicates))}"
    end

    :ok
  end
end
