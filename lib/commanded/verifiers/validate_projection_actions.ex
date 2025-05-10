defmodule AshCommanded.Commanded.Verifiers.ValidateProjectionActions do
  @moduledoc """
  Ensures that each projection references a valid action on the resource.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias Ash.Resource.Info, as: ResourceInfo
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    defined_actions = ResourceInfo.actions(resource) |> Enum.map(& &1.name) |> MapSet.new()

    Enum.each(Info.projections(resource), fn proj ->
      if proj[:action] && not MapSet.member?(defined_actions, proj[:action]) do
        raise DslError,
          path: [:commanded, :projections, proj.name],
          message:
            "Projection #{inspect(proj.name)} references missing action: #{inspect(proj[:action])}"
      end
    end)

    :ok
  end
end
