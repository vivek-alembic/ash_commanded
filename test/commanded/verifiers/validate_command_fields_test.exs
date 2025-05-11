defmodule AshCommanded.Commanded.Verifiers.ValidateCommandFieldsTest do
  use ExUnit.Case, async: true

  defmodule InvalidCommandFieldsResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    actions do
      create :create_user
    end

    commanded do
      commands do
        command :create_user do
          # :username is not an attribute
          fields([:id, :email, :username])
          action :create_user
        end
      end
    end
  end

  defmodule ValidCommandFieldsResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    actions do
      create :create_user
    end

    commanded do
      commands do
        command :create_user do
          fields([:id, :email])
          action :create_user
        end
      end
    end
  end

  test "raises error when command includes unknown fields" do
    assert_raise Spark.Error.DslError,
                 ~r/includes unknown fields: \[:username\]/,
                 fn ->
                   Code.ensure_compiled!(InvalidCommandFieldsResource)
                 end
  end

  test "passes when all command fields are valid attributes" do
    assert Code.ensure_compiled?(ValidCommandFieldsResource)
  end
end
