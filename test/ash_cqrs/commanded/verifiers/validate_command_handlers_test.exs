defmodule AshCommanded.Commanded.Verifiers.ValidateCommandHandlersTest do
  use ExUnit.Case, async: true

  defmodule DuplicateHandlersResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    actions do
      create :register
      create :register_alt
    end

    commanded do
      commands do
        command :register_user do
          fields([:id, :email])
          action :register
        end

        command :register_user_conflict do
          fields([:id, :email])
          action :register_alt
        end
      end
    end
  end

  defmodule UniqueHandlersResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    actions do
      create :create_account
      update :update_email
    end

    commanded do
      commands do
        command :create_account do
          fields([:id, :email])
          action :create_account
          handler_name(:handle_create)
        end

        command :update_email do
          fields([:id, :email])
          action :update_email
          handler_name(:handle_update)
        end
      end
    end
  end

  test "raises error when duplicate handler names are defined" do
    assert_raise Spark.Error.DslError,
                 ~r/Duplicate handler function names detected/,
                 fn ->
                   Code.ensure_compiled!(DuplicateHandlersResource)
                 end
  end

  test "passes when handler names are unique" do
    assert Code.ensure_compiled?(UniqueHandlersResource)
  end
end
