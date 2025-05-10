defmodule AshCommanded.Commanded.Verifiers.ValidateEventFields do
  @moduledoc """
  Ensures that every field listed in each event exists as an attribute in the resource.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias Ash.Resource.Info, as: ResourceInfo
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    attr_names = ResourceInfo.attributes(resource) |> Enum.map(& &1.name) |> MapSet.new()

    Enum.each(Info.events(resource), fn event ->
      missing_fields = Enum.reject(event.fields, &MapSet.member?(attr_names, &1))

      if missing_fields != [] do
        raise DslError,
          path: [:commanded, :events, event.name],
          message:
            "Event #{inspect(event.name)} includes unknown fields: #{inspect(missing_fields)}"
      end
    end)

    :ok
  end
end
