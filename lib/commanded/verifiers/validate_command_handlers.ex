defmodule AshCommanded.Commanded.Verifiers.ValidateCommandHandlers do
  @moduledoc """
  Ensures no two commands use the same handler function name within a resource.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    handler_names =
      Info.commands(resource)
      |> Enum.reject(&(&1[:autogenerate_handler?] == false))
      |> Enum.map(&(&1[:handler_name] || :handle))

    duplicates = handler_names -- Enum.uniq(handler_names)

    if duplicates != [] do
      raise DslError,
        path: [:commanded, :commands],
        message: "Duplicate handler function names detected: #{inspect(Enum.uniq(duplicates))}"
    end

    :ok
  end
end
