defmodule AshCommanded.Commanded.Transformers.GenerateMainRouterModuleTest do
  use ExUnit.Case, async: true

  defmodule SingleDomainResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :name, :string
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
    end
  end

  defmodule SingleTestDomain do
    use Ash.Domain

    resources do
      resource SingleDomainResource
    end
  end

  defmodule FirstResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :name, :string
    end

    commanded do
      commands do
        command :create_first do
          fields([:id, :name])
          identity_field(:id)
        end
      end

      events do
        event :first_created do
          fields([:id, :name])
        end
      end
    end
  end

  defmodule SecondResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :title, :string
    end

    commanded do
      commands do
        command :create_second do
          fields([:id, :title])
          identity_field(:id)
        end
      end

      events do
        event :second_created do
          fields([:id, :title])
        end
      end
    end
  end

  defmodule FirstDomain do
    use Ash.Domain

    resources do
      resource FirstResource
    end
  end

  defmodule SecondDomain do
    use Ash.Domain

    resources do
      resource SecondResource
    end
  end

  test "main router is created" do
    router_module = Module.concat(["AshCommanded", "Router"])
    assert Code.ensure_loaded?(router_module)
    
    # Check that router uses proper Commanded behavior
    assert Spark.implements_behaviour?(router_module, Commanded.Commands.Router)
    
    # Check router has dispatch functions
    assert function_exported?(router_module, :dispatch, 1)
    assert function_exported?(router_module, :dispatch, 2)
  end
end