# Events

Events in AshCommanded represent facts that have occurred in your system. They are the source of truth for the state of your aggregates in the event sourcing pattern.

## Defining Events

Events are defined in the `commanded` DSL extension for Ash resources:

```elixir
defmodule ECommerce.Customer do
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
      event :customer_registered do
        fields([:id, :email, :name])
      end

      event :customer_status_updated do
        fields([:id, :status])
      end
    end
  end
end
```

## Event Options

Each event can have the following options:

- `fields`: List of fields the event contains
- `event_name`: Override the generated event module name

## Generated Event Modules

For each event, AshCommanded generates an event module:

```elixir
defmodule ECommerce.Events.CustomerRegistered do
  @moduledoc """
  Event emitted when a customer is registered
  """

  @type t :: %__MODULE__{
    id: String.t(),
    email: String.t(),
    name: String.t()
  }

  defstruct [:id, :email, :name]
end
```

## Event Handling

Events are handled in several ways in AshCommanded:

### Aggregate State Updates

In the aggregate module, AshCommanded generates `apply/2` functions for each event to update the aggregate state:

```elixir
defmodule ECommerce.CustomerAggregate do
  defstruct [:id, :email, :name, :status]

  def apply(%__MODULE__{} = state, %ECommerce.Events.CustomerRegistered{} = event) do
    %__MODULE__{
      state |
      id: event.id,
      email: event.email,
      name: event.name
    }
  end

  def apply(%__MODULE__{} = state, %ECommerce.Events.CustomerStatusUpdated{} = event) do
    %__MODULE__{
      state |
      status: event.status
    }
  end
end
```

### Projections

Projections transform events into resource updates, allowing you to maintain read models. See the [Projections](projections.md) documentation for details.

### Event Handlers

Event handlers allow you to respond to events with side effects like sending notifications or integrating with external systems. See the [Event Handlers](event_handlers.md) documentation for more information.

## Choosing Between Projections and Event Handlers

When deciding how to handle events, consider the following:

- Use **projections** when you need to update your resource state or read models based on events
- Use **event handlers** when you need to perform side effects like sending notifications, integrating with external systems, or publishing events to other systems

You can use both together to create a complete system that maintains consistent read models while also performing necessary side effects.