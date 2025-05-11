defmodule AshCommanded.Commanded.Verifiers.ValidateProjectionEventsTest do
  use ExUnit.Case, async: true

  defmodule InvalidProjectionResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
    end

    commanded do
      events do
        event :valid_event do
          fields([:id])
        end
      end

      projections do
        projection :missing_event do
          event :non_existent_event
          changes(%{id: :id})
        end
      end
    end
  end

  defmodule ValidProjectionResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    commanded do
      events do
        event :user_registered do
          fields([:id, :email])
        end
      end

      projections do
        projection :user_registered do
          event :user_registered
          changes(%{id: :id, email: :email})
        end
      end
    end
  end

  test "raises error when a projection references a missing event" do
    assert_raise Spark.Error.DslError,
                 ~r/No matching event found for projection: :non_existent_event/,
                 fn ->
                   Code.ensure_compiled!(InvalidProjectionResource)
                 end
  end

  test "passes when projection references a valid event" do
    assert Code.ensure_compiled?(ValidProjectionResource)
  end
end
