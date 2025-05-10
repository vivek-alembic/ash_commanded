defmodule AshCommanded.Commanded.Transformers.GenerateCommandModulesOptionsTest do
  use ExUnit.Case, async: true

  defmodule CommandOptionsResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    @command_namespace AshCommanded.Commanded.GeneratedCommands

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    commanded do
      commands do
        command :register_user do
          fields([:id, :email])
          command_name(:CustomRegister)
        end

        command :skip_this do
          fields([:id])
          autogenerate?(false)
        end
      end
    end
  end

  alias AshCommanded.Commanded.GeneratedCommands.CustomRegister

  test "command_name option generates module with custom name" do
    assert Code.ensure_loaded?(CustomRegister)
    assert struct(CustomRegister, id: "1", email: "a@b.com")
  end

  test "autogenerate?: false skips module generation" do
    refute Code.ensure_loaded?(AshCommanded.Commanded.GeneratedCommands.SkipThis)
  end
end
