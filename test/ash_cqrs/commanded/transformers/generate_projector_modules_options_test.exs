defmodule AshCommanded.Commanded.Transformers.GenerateProjectorModulesOptionsTest do
  use ExUnit.Case, async: true

  defmodule ProjectionOptionsResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl],
      data_layer: Ash.DataLayer.Ets

    @event_namespace AshCommanded.Commanded.GeneratedEvents
    @projector_namespace AshCommanded.Commanded.ProjectorOptions

    ets do
      private? false
    end

    attributes do
      uuid_primary_key :id
      attribute :status, :string
    end

    actions do
      create :create

      update :mark_ready do
        change set_attribute(:status, "ready")
      end
    end

    commanded do
      events do
        event :resource_ready do
          fields([:id])
        end

        event :manual_only do
          fields([:id])
        end
      end

      projections do
        projection :resource_ready do
          projector_name(:CustomProjector)
          action :mark_ready
          changes(%{id: :id})
        end

        projection :manual_only do
          autogenerate?(false)
          action :mark_ready
          changes(%{id: :id})
        end
      end
    end
  end

  defmodule AshCommanded.Commanded.GeneratedEvents.ResourceReady, do: defstruct([:id])
  defmodule AshCommanded.Commanded.GeneratedEvents.ManualOnly, do: defstruct([:id])

  alias AshCommanded.Commanded.ProjectorOptions.CustomProjector

  test "projection with projector_name generates expected module" do
    assert Code.ensure_loaded?(CustomProjector)
  end

  test "projection with autogenerate? = false does not generate module" do
    refute Code.ensure_loaded?(AshCommanded.Commanded.ProjectorOptions.ManualOnlyProjector)
  end
end
