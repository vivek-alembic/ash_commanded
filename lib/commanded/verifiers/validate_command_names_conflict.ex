defmodule AshCommanded.Commanded.Verifiers.ValidateCommandNameConflicts do
  @moduledoc """
  Ensures that command names do not shadow unrelated resource actions.

  If a command shares the same name as a resource action, it must explicitly reference that action.
  This prevents accidental mismatches.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias Ash.Resource.Info, as: ResourceInfo
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    action_names = ResourceInfo.actions(resource) |> Enum.map(& &1.name) |> MapSet.new()

    Enum.each(Info.commands(resource), fn command ->
      command_name = command.name
      inferred_action = command[:action] || command.name

      if MapSet.member?(action_names, command_name) and inferred_action != command_name do
        raise DslError,
          path: [:commanded, :commands, command_name],
          message:
            "Command #{inspect(command_name)} shadows an action of the same name but refers to #{inspect(inferred_action)}. Please disambiguate."
      end
    end)

    :ok
  end
end
