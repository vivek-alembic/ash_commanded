defmodule AshCommanded.Commanded.Verifiers.ValidateProjectionChanges do
  @moduledoc """
  Ensures that each projection only updates known attributes,
  and only uses event fields or constants as values.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias Ash.Resource.Info, as: ResourceInfo
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    attr_names = ResourceInfo.attributes(resource) |> Enum.map(& &1.name) |> MapSet.new()
    events = Info.events(resource)

    Enum.each(Info.projections(resource), fn proj ->
      unless is_map(proj.changes) do
        raise DslError,
          path: [:commanded, :projections, proj.name],
          message: "Projection #{inspect(proj.name)} has an invalid `changes` declaration"
      end

      Enum.each(proj.changes, fn {target, source} ->
        unless MapSet.member?(attr_names, target) do
          raise DslError,
            path: [:commanded, :projections, proj.name],
            message: "Unknown attribute in projection changes: #{inspect(target)}"
        end

        unless valid_source?(source, proj.event, events) do
          raise DslError,
            path: [:commanded, :projections, proj.name],
            message:
              "Invalid source #{inspect(source)} for target #{inspect(target)} in projection #{inspect(proj.name)}"
        end
      end)
    end)

    :ok
  end

  defp valid_source?(source, event_name, events) do
    case source do
      {:const, _} ->
        true

      field when is_atom(field) ->
        case Enum.find(events, &(&1.name == event_name)) do
          nil -> false
          event -> field in event.fields
        end

      _ ->
        false
    end
  end
end
