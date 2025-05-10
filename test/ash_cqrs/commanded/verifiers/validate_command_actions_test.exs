defmodule AshCommanded.Commanded.Verifiers.ValidateCommandActionsTest do
  use ExUnit.Case, async: true

  defmodule MissingActionCommandResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    commanded do
      commands do
        command :missing_action_command do
          fields([:id, :email])
        end
      end
    end
  end

  defmodule ValidCommandActionResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    actions do
      create :create_user
      update :update_email
    end

    commanded do
      commands do
        command :create_user do
          fields([:id, :email])
        end

        command :update_email do
          fields([:id, :email])
        end
      end
    end
  end

  test "raises error if command refers to missing action" do
    assert_raise Spark.Error.DslError,
                 ~r/Command `:missing_action_command` references missing action: :missing_action_command/,
                 fn ->
                   Code.ensure_compiled!(MissingActionCommandResource)
                 end
  end

  test "passes if all command actions are valid" do
    assert Code.ensure_compiled?(ValidCommandActionResource)
  end
end
