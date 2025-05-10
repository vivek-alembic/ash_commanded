defmodule AshCommanded.Commanded.Transformers.GenerateDomainRouterModuleTest do
  use ExUnit.Case, async: true

  defmodule TestResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :name, :string
      attribute :status, :string
    end

    identities do
      identity :unique_id, [:id]
    end

    commanded do
      commands do
        command :create_resource do
          fields([:id, :name])
          identity_field(:id)
        end

        command :update_status do
          fields([:id, :status])
        end
      end

      events do
        event :resource_created do
          fields([:id, :name])
        end

        event :status_updated do
          fields([:id, :status])
        end
      end
    end
  end

  defmodule TestDomain do
    use Ash.Domain

    resources do
      resource TestResource
    end
  end

  test "generates domain router module with dispatch rules" do
    router_module = Module.concat([TestDomain, "Router"])
    assert Code.ensure_loaded?(router_module)

    # Check that router uses proper Commanded behavior
    assert Spark.implements_behaviour?(router_module, Commanded.Commands.Router)

    # Check router public functions - testing internals is tricky without DynamicSupervisor
    assert function_exported?(router_module, :dispatch, 1)
    assert function_exported?(router_module, :dispatch, 2)
  end
end