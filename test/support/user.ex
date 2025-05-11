defmodule MyApp.User do
  use Ash.Resource,
    domain: MyApp.Domain
    extensions: [AshCommanded.Commanded.Dsl]

  attributes do
    
  end

  commanded do
    commands do
      command :register_user do
        fields([:id, :email, :name])
        identity_field(:id)
      end

      command :set_user_status do
        fields([:id, :status])
        identity_field(:id)
      end
    end

    events do
      event :user_registered do
        fields([:id, :email, :name])
      end

      event :email_changed do
        fields([:id, :email])
      end

    end

    projections do
      # Create a new record when user is registered
      projection :user_registered do
        action(:create)
        changes(%{
          status: "active",
          registered_at: &DateTime.utc_now/0
        })
      end
      
      # Update specific fields when email changes
      projection :email_changed do
        action(:update_by_id)
        changes(fn event ->
          %{
            email: event.email,
            updated_at: DateTime.utc_now()
          }
        end)
      end
    end
  end
end
