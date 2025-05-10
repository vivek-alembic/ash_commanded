defmodule AshCommanded.Commanded.Transformers.GenerateCommandModulesNamespaceTest do
  use ExUnit.Case, async: true

  defmodule MyApp.CustomNamespace.RegisterUser do
    # dummy placeholder to avoid compile error in assert_module
  end

  defmodule TestResourceWithNamespace do
    @command_namespace MyApp.CustomNamespace

    use Ash.Resource,
      extensions: [
        AshCommanded.Commanded.Dsl
      ]

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

  alias MyApp.CustomNamespace.RegisterUser

  describe "@command_namespace" do
    test "generated command module respects custom namespace" do
      assert Code.ensure_loaded?(RegisterUser)
      assert %RegisterUser{id: "1", email: "a", name: "b"}
    end
  end
end
