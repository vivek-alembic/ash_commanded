defmodule AshCommanded.Commanded.Transformers.DuplicateCommandNameTest do
  use ExUnit.Case, async: true

  test "raises error when command_name leads to duplicate modules" do
    assert_raise Spark.Error.DslError, ~r/Duplicate command module names detected/, fn ->
      defmodule DuplicateCommandModuleResource do
        use Ash.Resource,
          extensions: [AshCommanded.Commanded.Dsl]

        @command_namespace AshCommanded.Commanded.GeneratedCommands

        attributes do
          uuid_primary_key :id
          attribute :email, :string
        end

        commanded do
          commands do
            command :create_user do
              command_name(:Shared)
              fields([:id])
            end

            command :make_user do
              command_name(:Shared)
              fields([:id])
            end
          end
        end
      end
    end
  end
end
