defmodule AshCommanded.Commanded.Verifiers.ValidateCommandActions do
  @moduledoc """
  Ensures that each command refers to a valid action in the resource.

  If an action is not explicitly specified, it is assumed to match the command's name.
  """

  @behaviour Spark.Dsl.Verifier

  alias Spark.Error.DslError
  alias AshCommanded.Commanded.Info

  @impl true
  def verify(resource) do
    defined_actions = Ash.Resource.Info.actions(resource) |> Enum.map(& &1.name) |> MapSet.new()

    Enum.each(Info.commands(resource), fn cmd ->
      action_name = cmd[:action] || cmd.name

      unless MapSet.member?(defined_actions, action_name) do
        raise DslError,
          path: [:commanded, :commands, cmd.name],
          message: "Command `#{cmd.name}` references missing action: #{inspect(action_name)}"
      end
    end)

    :ok
  end
end
