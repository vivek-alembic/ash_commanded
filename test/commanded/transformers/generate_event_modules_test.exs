defmodule AshCommanded.Commanded.Transformers.GenerateEventModulesTest do
  use ExUnit.Case, async: true

  defmodule TestEventResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    @event_namespace AshCommanded.Commanded.GeneratedEvents

    attributes do
      uuid_primary_key :id
      attribute :email, :string
      attribute :name, :string
    end

    commanded do
      events do
        event :user_registered do
          fields([:id, :email, :name])
        end
      end
    end
  end

  alias AshCommanded.Commanded.GeneratedEvents.UserRegistered

  describe "GenerateEventModules" do
    test "generates a module for the event" do
      assert Code.ensure_loaded?(UserRegistered)
      assert struct(UserRegistered, id: "123", email: "a@test.com", name: "Test User")
    end

    test "generated struct has correct fields" do
      event = struct(UserRegistered)
      assert Map.has_key?(event, :id)
      assert Map.has_key?(event, :email)
    end

    test "typespec is attached to the module" do
      assert is_list(UserRegistered.__info__(:attributes))
    end
  end
end
