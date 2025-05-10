defmodule AshCommanded.Commanded.Verifiers.ValidateProjectionActionsTest do
  use ExUnit.Case, async: true

  defmodule InvalidProjectionActionResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :status, :string
    end

    commanded do
      events do
        event :user_activated do
          fields([:id])
        end
      end

      projections do
        projection :user_activated do
          event :user_activated
          action :nonexistent_action
          changes(%{status: {:const, "active"}})
        end
      end
    end
  end

  defmodule ValidProjectionActionResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :status, :string
    end

    actions do
      update :activate
    end

    commanded do
      events do
        event :user_activated do
          fields([:id])
        end
      end

      projections do
        projection :user_activated do
          event :user_activated
          action :activate
          changes(%{status: {:const, "active"}})
        end
      end
    end
  end

  test "raises error if projection references a missing action" do
    assert_raise Spark.Error.DslError,
                 ~r/Projection :user_activated references missing action: :nonexistent_action/,
                 fn ->
                   Code.ensure_compiled!(InvalidProjectionActionResource)
                 end
  end

  test "passes when projection action is valid" do
    assert Code.ensure_compiled?(ValidProjectionActionResource)
  end
end
