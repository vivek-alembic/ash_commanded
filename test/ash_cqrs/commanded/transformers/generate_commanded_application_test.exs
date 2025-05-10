defmodule AshCommanded.Commanded.Transformers.GenerateCommandedApplicationTest do
  use ExUnit.Case, async: true

  defmodule ApplicationResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :name, :string
      attribute :status, :string
    end

    commanded do
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

  defmodule ApplicationDomain do
    use Ash.Domain

    resources do
      resource ApplicationResource
    end

    commanded do
      application do
        otp_app :application_test
        name TestApp
        event_store Commanded.EventStore.Adapters.InMemory
      end
    end
  end

  defmodule CustomNameDomain do
    use Ash.Domain

    resources do
      resource ApplicationResource
    end

    commanded do
      application do
        otp_app :custom_test
        name MyCustomApp
      end
    end
  end

  defmodule NoConfigDomain do
    use Ash.Domain

    resources do
      resource ApplicationResource
    end
  end

  test "generates commanded application module with router and projector" do
    assert Code.ensure_compiled?(TestApp)
    assert Code.ensure_loaded?(TestApp)
    
    # Verify that the application uses Commanded.Application
    assert Spark.implements_behaviour?(TestApp, Commanded.Application)
    
    # Verify that the application has start_link function for supervision
    assert function_exported?(TestApp, :start_link, 0)
    assert function_exported?(TestApp, :start_link, 1)
    assert function_exported?(TestApp, :child_spec, 1)
  end

  test "respects custom name setting" do
    assert Code.ensure_compiled?(MyCustomApp)
    assert Code.ensure_loaded?(MyCustomApp)
    
    # Verify that the application uses Commanded.Application
    assert Spark.implements_behaviour?(MyCustomApp, Commanded.Application)
  end

  test "does not generate application module when no config provided" do
    # Default naming would be NoConfigDomainCommandedApp
    default_name = NoConfigDomain.CommandedApp
    refute Code.ensure_loaded?(default_name)
  end
end