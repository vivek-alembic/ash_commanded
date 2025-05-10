# Projections

Projections in AshCommanded define how events affect the state of your resources. They are the read model update mechanism in the CQRS pattern.

## Defining Projections

Projections are defined in the `commanded` DSL extension for Ash resources:

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshCommanded.Commanded.Dsl]

  attributes do
    uuid_primary_key :id
    attribute :email, :string
    attribute :name, :string
    attribute :status, :string
  end

  commanded do
    events do
      event :user_registered do
        fields([:id, :email, :name])
      end

      event :user_status_updated do
        fields([:id, :status])
      end
    end

    projections do
      projection :user_registered do
        action(:create)
        changes(%{
          status: "pending"
        })
      end

      projection :user_status_updated do
        action(:update_by_id)
        changes(&Map.take(&1, [:status]))
      end
    end
  end
end
```

## Projection Options

Each projection can have the following options:

- `action`: The Ash action to use when handling the event (`:create`, `:update`, etc.)
- `changes`: Static map or function to determine the changes to apply
- `projector_name`: Override the generated projector module name

## Generated Projector Modules

AshCommanded generates a projector module for each resource with projections. This projector is a Commanded event handler that subscribes to events and updates the read model.

```elixir
defmodule MyApp.Projectors.UserProjector do
  @moduledoc """
  Projector for User-related events
  """

  use Commanded.Projections.Ecto, 
    name: "MyApp.Projectors.UserProjector"

  # Each projection gets a project/3 function
  project(%MyApp.Events.UserRegistered{} = event, _metadata, fn _context ->
    Ash.Changeset.new(MyApp.User, event)
    |> Ash.Changeset.for_action(:create, %{
      id: event.id,
      email: event.email, 
      name: event.name,
      status: "pending"
    })
    |> Ash.create()
  end)
  
  project(%MyApp.Events.UserStatusUpdated{} = event, _metadata, fn _context ->
    Ash.Changeset.new(MyApp.User, event)
    |> Ash.Changeset.for_action(:update_by_id, %{
      status: event.status
    })
    |> Ash.update()
  end)
  
  # Helper functions for applying different action types
  defp apply_action_fn(:create), do: &Ash.create/1
  defp apply_action_fn(:update), do: &Ash.update/1
  defp apply_action_fn(:destroy), do: &Ash.destroy/1
end
```

## Registering Projectors with Commanded

The generated projectors need to be registered with your Commanded application to start processing events. Add them to your application's supervisor tree:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # ...other children
      
      # Start your projectors
      MyApp.Projectors.UserProjector
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

For more complex projection needs, you can customize the `project/3` function directly in your own projector module:

```elixir
defmodule MyApp.CustomProjector do
  use Commanded.Projections.Ecto, name: "MyApp.CustomProjector"

  project(%MyApp.Events.UserRegistered{} = event, metadata, fn _context ->
    # Access event and metadata
    user_id = event.id
    timestamp = metadata.created_at
    
    # Custom projection logic
    Ash.Changeset.new(MyApp.User)
    |> Ash.Changeset.for_action(:create, %{
      id: user_id,
      email: event.email,
      name: event.name,
      status: "pending",
      registered_at: timestamp
    })
    |> Ash.create()
  end)
end
```

Each resource typically gets one projector module containing handlers for all projections. The projector:

1. Automatically registers with Commanded to receive events
2. Processes events in real-time as they occur
3. Updates the read models (resources) using Ash actions
4. Maintains consistency between write and read models

## Customizing Projector Generation

You can customize the projector generation with several options:

```elixir
projection :user_registered do
  # Specify the action to perform (create, update, destroy)
  action(:create)
  
  # Changes to apply
  changes(%{status: "active"})
  
  # Custom projector module name
  projector_name(:CustomUserProjector)
  
  # Disable projector generation for this projection
  autogenerate?(false)
end
```

For a resource with many projectors, you can also set the projector namespace:

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshCommanded.Commanded.Dsl]
    
  # Set custom namespace for all projectors
  @projector_namespace MyApp.CustomProjectors
  
  # Resource definition...
end
```

## Change Types

The `changes` option supports two formats:

1. Static map - simple key-value changes:
```elixir
changes(%{
  status: "active"
})
```

2. Function - dynamic changes based on the event:
```elixir
changes(fn event ->
  %{
    status: event.status,
    last_updated: DateTime.utc_now()
  }
end)
```

Or more concisely with capture syntax:
```elixir
changes(&Map.take(&1, [:status]))
```