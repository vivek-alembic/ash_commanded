defmodule AshCommanded.Commanded.Transformers.GenerateAggregateModuleTest do
  use ExUnit.Case, async: true

  defmodule AggregateTestResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :email, :string
      attribute :status, :string
    end

    commanded do
      events do
        event :user_registered do
          fields([:id, :email, :status])
        end
      end
    end
  end

  test "generates aggregate module with struct and apply/2" do
    mod = Module.concat([AshCommanded, Commanded, Aggregates, "AggregateTestResourceAggregate"])
    assert Code.ensure_compiled?(AggregateTestResource)
    assert Code.ensure_loaded?(mod)

    struct = struct(mod, id: nil, email: nil, status: nil)

    event = %AshCommanded.Commanded.Events.UserRegistered{
      id: "1",
      email: "test@example.com",
      status: "active"
    }

    updated = apply(mod, :apply, [struct, event])

    assert updated.id == "1"
    assert updated.email == "test@example.com"
    assert updated.status == "active"
  end
end
