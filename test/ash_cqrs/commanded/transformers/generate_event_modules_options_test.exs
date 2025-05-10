defmodule AshCommanded.Commanded.Transformers.GenerateEventModulesOptionsTest do
  use ExUnit.Case, async: true

  defmodule EventOptionsResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    @event_namespace AshCommanded.Commanded.GeneratedEvents

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    commanded do
      events do
        event :user_registered do
          fields([:id, :email])
          event_name(:CustomUserRegistered)
        end

        event :ignored_event do
          fields([:id])
          autogenerate?(false)
        end
      end
    end
  end

  alias AshCommanded.Commanded.GeneratedEvents.CustomUserRegistered

  test "event_name option generates module with custom name" do
    assert Code.ensure_loaded?(CustomUserRegistered)
    assert struct(CustomUserRegistered, id: "1", email: "x@y.com")
  end

  test "autogenerate?: false skips module generation" do
    refute Code.ensure_loaded?(AshCommanded.Commanded.GeneratedEvents.IgnoredEvent)
  end
end
