defmodule AshCommanded.Commanded.Verifiers.ValidateCommandNamesTest do
  use ExUnit.Case, async: true

  defmodule DuplicateCommandNamesResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    actions do
      create :register_user
      update :register_user
    end

    commanded do
      commands do
        command :register_user do
          fields([:id, :email])
          action :register_user
        end

        command :register_user do
          fields([:id, :email])
          action :register_user
        end
      end
    end
  end

  defmodule UniqueCommandNamesResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    actions do
      create :create_user
      update :change_email
    end

    commanded do
      commands do
        command :create_user do
          fields([:id, :email])
          action :create_user
        end

        command :change_email do
          fields([:id, :email])
          action :change_email
        end
      end
    end
  end

  test "raises error when duplicate command names exist" do
    assert_raise Spark.Error.DslError,
                 ~r/Duplicate command names detected/,
                 fn ->
                   Code.ensure_compiled!(DuplicateCommandNamesResource)
                 end
  end

  test "passes when all command names are unique" do
    assert Code.ensure_compiled?(UniqueCommandNamesResource)
  end
end
