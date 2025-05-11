defmodule AshCommanded.Commanded.Verifiers.ValidateProjectionChangesTest do
  use ExUnit.Case, async: true

  defmodule InvalidProjectionChangesResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
      attribute :status, :string
    end

    actions do
      update :update_status
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
          action :update_status

          changes(%{
            # invalid source type
            status: {:unknown_tag, "active"},
            # invalid field
            email: :not_in_event_fields,
            # invalid target
            not_an_attr: {:const, "bad"}
          })
        end
      end
    end
  end

  defmodule ValidProjectionChangesResource do
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

          changes(%{
            id: :id,
            status: {:const, "active"}
          })
        end
      end
    end
  end

  test "raises when projection includes invalid change targets or sources" do
    assert_raise Spark.Error.DslError, ~r/Invalid source|Unknown attribute/, fn ->
      Code.ensure_compiled!(InvalidProjectionChangesResource)
    end
  end

  test "passes when projection changes are valid" do
    assert Code.ensure_compiled?(ValidProjectionChangesResource)
  end
end
