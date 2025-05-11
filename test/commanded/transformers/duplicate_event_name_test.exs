defmodule AshCommanded.Commanded.Transformers.DuplicateEventNameTest do
  use ExUnit.Case, async: true

  test "raises error when event_name values conflict" do
    assert_raise Spark.Error.DslError, ~r/Duplicate event module names detected/, fn ->
      defmodule ConflictingEventNamesResource do
        use Ash.Resource,
          extensions: [AshCommanded.Commanded.Dsl]

        @event_namespace AshCommanded.Commanded.GeneratedEvents

        attributes do
          uuid_primary_key :id
        end

        commanded do
          events do
            event :user_signed_up do
              event_name(:Conflict)
              fields([:id])
            end

            event :user_invited do
              event_name(:Conflict)
              fields([:id])
            end
          end
        end
      end
    end
  end
end
