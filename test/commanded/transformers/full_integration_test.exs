defmodule AshCommanded.Commanded.Transformers.FullIntegrationTest do
  use ExUnit.Case, async: true

  defmodule FullTestResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    @command_namespace AshCommanded.Commanded.Full.Commands
    @event_namespace AshCommanded.Commanded.Full.Events
    @projection_namespace AshCommanded.Commanded.Full.Projections

    attributes do
      uuid_primary_key :id
      attribute :email, :string
      attribute :name, :string
      attribute :status, :atom, constraints: [one_of: [:pending, :active]]
    end

    commanded do
      commands do
        command :register_user do
          fields([:id, :email, :name])
          identity_field(:id)
        end
      end

      events do
        event :user_registered do
          fields([:id, :email, :name])
        end
      end

      projections do
        projection :user_registered do
          changes(%{status: :active})
        end
      end
    end
  end

  alias AshCommanded.Commanded.Full.Commands.RegisterUser
  alias AshCommanded.Commanded.Full.Events.UserRegistered
  alias AshCommanded.Commanded.Full.Projections.UserRegistered, as: Projector

  describe "full DSL transformer integration" do
    test "command module was generated" do
      assert Code.ensure_loaded?(RegisterUser)
      assert struct(RegisterUser, id: "123", name: "abc", email: "x@y.com")
    end

    test "event module was generated" do
      assert Code.ensure_loaded?(UserRegistered)
      assert struct(UserRegistered, id: "123", name: "abc", email: "x@y.com")
    end

    test "projection module was generated and can apply changes" do
      state = %{status: :pending}
      result = Projector.handle(state, %{status: :active})
      assert result == %{status: :active}
    end
  end
end
