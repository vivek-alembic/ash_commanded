 defmodule MyApp.User do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    attributes do
      uuid_primary_key :id
      attribute :name, :string
      attribute :email, :string
      attribute :status, :atom, constraints: [one_of: [:pending, :active]]
    end

    identities do
      identity :unique_id, [:id]
    end

    actions do
      defaults [:read]

      create :register do
        accept [:name, :email]
        change set_attribute(:status, :pending)
      end

      update :confirm_email do
        accept []
        change set_attribute(:status, :active)
      end
    end

    commanded do
      commands do
        command :register_user do
          fields([:id, :name, :email])
          identity_field(:id)
          action :register
        end

        command :confirm_email do
          fields([:id])
          identity_field(:id)
          action :confirm_email
        end
      end

      events do
        event :user_registered do
          fields([:id, :name, :email])
        end

        event :email_confirmed do
          fields([:id])
        end
      end

      projections do
        projection :user_registered do
          action(:create)
          changes(%{
            status: :pending
          })
        end

        projection :email_confirmed do
          action(:update_by_id)
          changes(%{
            status: :active
          })
        end
      end
    end
  end
