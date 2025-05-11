defmodule AshCommanded.Commanded.Transformers.InvalidProjectorNameTest do
  use ExUnit.Case, async: true

  test "raises error when multiple projector_name values are defined" do
    assert_raise Spark.Error.DslError, ~r/Multiple conflicting projector_name values found/, fn ->
      defmodule ConflictingProjectorNamesResource do
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
          update :mark_ready
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
              projector_name(:ProjectorA)
              action :create
              changes(%{id: :id})
            end

            projection :b do
              projector_name(:ProjectorB)
              action :mark_ready
              changes(%{id: :id})
            end
          end
        end
      end
    end
  end
end
