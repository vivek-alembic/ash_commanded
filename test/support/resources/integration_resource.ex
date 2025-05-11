  defmodule Test.Support.IntegrationResource do
    use Ash.Resource,
      domain: Test.SupportIntegrationDomain,
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
