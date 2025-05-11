defmodule AshCommanded.Commanded.Verifiers.ValidateEventNamesTest do
  use ExUnit.Case, async: true

  defmodule DuplicateEventNamesResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
    end

    commanded do
      events do
        event :user_registered do
          fields([:id])
        end

        event :user_registered do
          fields([:id])
        end
      end
    end
  end

  defmodule UniqueEventNamesResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
    end

    commanded do
      events do
        event :user_registered do
          fields([:id])
        end

        event :user_activated do
          fields([:id])
        end
      end
    end
  end

  test "raises error for duplicate event names" do
    assert_raise Spark.Error.DslError,
                 ~r/Duplicate event names detected: \[:user_registered\]/,
                 fn ->
                   Code.ensure_compiled!(DuplicateEventNamesResource)
                 end
  end

  test "passes when event names are unique" do
    assert Code.ensure_compiled?(UniqueEventNamesResource)
  end
end
