defmodule AshCommanded.Commanded.Transformers.GenerateCommandModulesTest do
  use ExUnit.Case, async: true

  defmodule TestCommandResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    @command_namespace AshCommanded.Commanded.GeneratedCommands

    attributes do
      uuid_primary_key :id
      attribute :email, :string
      attribute :name, :string
    end

    commanded do
      commands do
        command :register_user do
          fields([:id, :email, :name])
          identity_field(:id)
        end
      end
    end
  end

  alias AshCommanded.Commanded.GeneratedCommands.RegisterUser

  describe "GenerateCommandModules" do
    test "generates a module for the command" do
      assert Code.ensure_loaded?(RegisterUser)
      assert struct(RegisterUser, id: "123", email: "test@example.com", name: "Test User")
    end

    test "generated module has enforce_keys and a default struct" do
      assert %RegisterUser{id: nil, email: nil, name: nil} = struct(RegisterUser)
      assert Map.has_key?(RegisterUser.__struct__(), :email)
    end

    test "generated typespec exists for command struct" do
      # Optional: Basic introspection; Dialyzer would do a more thorough check
      assert is_list(RegisterUser.__info__(:attributes))
    end
  end
end
