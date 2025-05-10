defmodule AshCommanded.Commanded.Verifiers.ValidateCommandNameConflictsTest do
  use ExUnit.Case, async: true

  defmodule ConflictingCommandNameResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
    end

    actions do
      create :register
      create :create_user
    end

    commanded do
      commands do
        command :register do
          fields([:id])
          # conflict: command name = :register but action ≠ :register
          action :create_user
        end
      end
    end
  end

  defmodule ValidCommandNameResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
    end

    actions do
      create :register
    end

    commanded do
      commands do
        command :register do
          fields([:id])
          action :register
        end
      end
    end
  end

  test "raises error if command shadows action name but points to different action" do
    assert_raise Spark.Error.DslError,
                 ~r/Command register shadows an action of the same name but refers to :create_user/,
                 fn ->
                   Code.ensure_compiled!(ConflictingCommandNameResource)
                 end
  end

  test "passes if command name and referenced action match" do
    assert Code.ensure_compiled?(ValidCommandNameResource)
  end
end
