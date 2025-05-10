defmodule AshCommanded.Commanded.Transformers.DuplicateProjectionNameTest do
  use ExUnit.Case, async: true

  test "raises error when projector_name is duplicated" do
    assert_raise Spark.Error.DslError, ~r/Multiple conflicting projector_name values found/, fn ->
      defmodule ConflictingProjectionNamesResource do
        use Ash.Resource,
          extensions: [AshCommanded.Commanded.Dsl],
          data_layer: Ash.DataLayer.Ets

        @event_namespace AshCommanded.Commanded.GeneratedEvents

        ets do
          private? true
        end

        attributes do
          uuid_primary_key :id
        end

        actions do
          create :create
          update :update_status
        end

        commanded do
          events do
            event :a do
              fields([:id])
            end

            event :b do
              fields([:id])
            end
          end

          projections do
            projection :a do
              projector_name(:Conflicting)
              action :create
              changes(%{id: :id})
            end

            projection :b do
              projector_name(:Another)
              action :update_status
              changes(%{id: :id})
            end
          end
        end
      end
    end
  end
end
