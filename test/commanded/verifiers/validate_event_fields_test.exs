defmodule AshCommanded.Commanded.Verifiers.ValidateEventFieldsTest do
  use ExUnit.Case, async: true

  defmodule InvalidEventFieldsResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    commanded do
      events do
        event :user_created do
          # :name is not an attribute
          fields([:id, :email, :name])
        end
      end
    end
  end

  defmodule ValidEventFieldsResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
      attribute :name, :string
    end

    commanded do
      events do
        event :user_created do
          fields([:id, :email, :name])
        end
      end
    end
  end

  test "raises error when event fields include unknown attributes" do
    assert_raise Spark.Error.DslError,
                 ~r/Event :user_created includes unknown fields: \[:name\]/,
                 fn ->
                   Code.ensure_compiled!(InvalidEventFieldsResource)
                 end
  end

  test "passes when all event fields match resource attributes" do
    assert Code.ensure_compiled?(ValidEventFieldsResource)
  end
end
