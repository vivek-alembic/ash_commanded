defmodule AshCommanded.Commanded.Transformers.AppIntegrationTest do
  use ExUnit.Case, async: true

  defmodule IntegrationResource do
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
      end

      events do
        event :resource_created do
          fields([:id, :name])
        end
      end

      projections do
        projection :resource_created do
          action(:create)
          changes(%{status: "active"})
        end
      end
    end
  end

  defmodule IntegrationDomain do
    use Ash.Domain

    resources do
      resource IntegrationResource
    end

    commanded do
      application do
        otp_app :integration_test
        name IntegrationApp
        event_store Commanded.EventStore.Adapters.InMemory
      end
    end
  end

  test "application has proper structure and includes projectors" do
    # Application module is generated
    assert Code.ensure_compiled?(IntegrationApp)
    assert Code.ensure_loaded?(IntegrationApp)
    
    # Router is configured in the application
    domain_router = Module.concat([IntegrationDomain, "Router"])
    assert Code.ensure_loaded?(domain_router)
    
    # Verify projector is included in the supervisor
    projector_module = Module.concat(["Projectors", "IntegrationResourceProjector"])
    assert Code.ensure_loaded?(projector_module)
    
    # The supervision tree should include the projector
    assert function_exported?(IntegrationApp, :start_link, 0)
    assert function_exported?(IntegrationApp, :child_spec, 1)
    
    # Check if the router is properly configured
    assert function_exported?(domain_router, :dispatch, 1)
    assert function_exported?(domain_router, :dispatch, 2)
  end
  
  test "can disable supervisor with include_supervisor?: false" do
    defmodule NoSupervisorDomain do
      use Ash.Domain

      resources do
        resource IntegrationResource
      end

      commanded do
        application do
          otp_app :no_supervisor_test
          name NoSupervisorApp
          include_supervisor? false
        end
      end
    end
    
    assert Code.ensure_compiled?(NoSupervisorApp)
    assert Code.ensure_loaded?(NoSupervisorApp)
    
    # Application should not have start_link function
    refute function_exported?(NoSupervisorApp, :start_link, 0)
    refute function_exported?(NoSupervisorApp, :start_link, 1)
    refute function_exported?(NoSupervisorApp, :child_spec, 1)
  end
end