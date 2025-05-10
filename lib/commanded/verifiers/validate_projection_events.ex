defmodule AshCommanded.Commanded.Verifiers.ValidateProjectionEvents do
  @moduledoc """
  Ensures that any projections refer to a valid event defined in the same resource.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    event_names = Info.events(resource) |> Enum.map(& &1.name) |> MapSet.new()

    Enum.each(Info.projections(resource), fn proj ->
      if not MapSet.member?(event_names, proj.event) do
        raise DslError,
          path: [:commanded, :projections, proj.name],
          message: "No matching event found for projection: #{inspect(proj.event)}"
      end
    end)

    :ok
  end
end
