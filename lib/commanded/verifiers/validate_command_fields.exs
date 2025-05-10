defmodule AshCommanded.Commanded.Verifiers.ValidateCommandFields do
  @moduledoc """
  Ensures that all fields declared in a command exist as attributes in the resource.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    attr_names = Ash.Resource.Info.attributes(resource) |> Enum.map(& &1.name) |> MapSet.new()

    Enum.each(Info.commands(resource), fn command ->
      missing = Enum.reject(command.fields, &MapSet.member?(attr_names, &1))

      if missing != [] do
        raise DslError,
          path: [:commanded, :commands, command.name],
          message: "Command #{command.name} includes unknown fields: #{inspect(missing)}"
      end
    end)

    :ok
  end
end
