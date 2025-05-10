defmodule AshCommanded.Commanded.Transformers.GenerateProjectionModulesTest do
  use ExUnit.Case, async: true

  defmodule TestProjectionResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    @projection_namespace AshCommanded.Commanded.GeneratedProjections

    attributes do
      uuid_primary_key :id
      attribute :status, :atom, constraints: [one_of: [:pending, :active]]
    end

    commanded do
      projections do
        projection :user_registered do
          changes(%{status: :active})
        end
      end
    end
  end

  alias AshCommanded.Commanded.GeneratedProjections.UserRegistered

  describe "GenerateProjectionModules" do
    test "generates a module for the projection" do
      assert Code.ensure_loaded?(UserRegistered)
    end

    test "generated handle/2 updates state based on projection changes" do
      initial_state = %{status: :pending}
      result = UserRegistered.handle(initial_state, %{status: :active})

      assert result == %{status: :active}
    end
  end
end
