defmodule AshCommanded.Commanded.Transformers.GenerateProjectorModulesTest do
  use ExUnit.Case, async: true

  defmodule ProjectorResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl],
      data_layer: Ash.DataLayer.Ets

    @projector_namespace AshCommanded.Commanded.GeneratedProjectors
    @event_namespace AshCommanded.Commanded.GeneratedEvents

    ets do
      private? false
    end

    attributes do
      uuid_primary_key :id
      attribute :email, :string
      attribute :status, :atom, constraints: [one_of: [:pending, :active, :suspended]]
    end

    actions do
      create :create

      update :activate do
        change set_attribute(:status, :active)
      end

      update :suspend_user do
        change set_attribute(:status, :suspended)
      end

      destroy :delete
    end

    commanded do
      events do
        event :user_registered do
          fields([:id, :email])
        end

        event :user_suspended do
          fields([:id])
        end

        event :user_deleted do
          fields([:id])
        end
      end

      projections do
        projection :user_registered do
          action :create
          changes(%{id: :id, email: :email})
        end

        projection :user_suspended do
          action :suspend_user
          changes(%{id: :id})
        end

        projection :user_deleted do
          action :delete
          changes(%{id: :id})
        end
      end
    end
  end

  defmodule AshCommanded.Commanded.GeneratedEvents.UserRegistered, do: defstruct([:id, :email])
  defmodule AshCommanded.Commanded.GeneratedEvents.UserSuspended, do: defstruct([:id])
  defmodule AshCommanded.Commanded.GeneratedEvents.UserDeleted, do: defstruct([:id])

  alias AshCommanded.Commanded.GeneratedProjectors.ProjectorResourceProjector
  alias ProjectorResource

  setup do
    :ok = Ash.DataLayer.Ets.start_repo(ProjectorResource)
    :ok
  end

  test "create projection creates resource" do
    event = %AshCommanded.Commanded.GeneratedEvents.UserRegistered{
      id: Ecto.UUID.generate(),
      email: "test@example.com"
    }

    assert {:ok, %ProjectorResource{id: _, email: "test@example.com"}} =
             ProjectorResourceProjector.project(event, %{}, %{})
  end

  test "custom action projection sets status to :suspended" do
    {:ok, user} =
      Ash.Changeset.for_create(ProjectorResource, :create, %{email: "a@test.com"})
      |> Ash.create()

    event = %AshCommanded.Commanded.GeneratedEvents.UserSuspended{id: user.id}

    assert {:ok, %ProjectorResource{status: :suspended}} =
             ProjectorResourceProjector.project(event, %{}, %{})
  end

  test "destroy projection deletes the resource" do
    {:ok, user} =
      Ash.Changeset.for_create(ProjectorResource, :create, %{email: "z@test.com"})
      |> Ash.create()

    event = %AshCommanded.Commanded.GeneratedEvents.UserDeleted{id: user.id}

    assert {:ok, %ProjectorResource{}} =
             ProjectorResourceProjector.project(event, %{}, %{})

    assert [] = Ash.read!(ProjectorResource)
  end
end
