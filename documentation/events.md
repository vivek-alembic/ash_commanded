# Events

Events in AshCommanded represent facts that have occurred in your system. They are the source of truth for the state of your aggregates in the event sourcing pattern.

## Defining Events

Events are defined in the `commanded` DSL extension for Ash resources:

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
defmodule MyApp.Events.UserRegistered do
  @moduledoc """
  Event emitted when a user is registered
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

In the aggregate module, AshCommanded generates `apply/2` functions for each event to update the aggregate state:

```elixir
defmodule MyApp.UserAggregate do
  defstruct [:id, :email, :name, :status]

  def apply(%__MODULE__{} = state, %MyApp.Events.UserRegistered{} = event) do
    %__MODULE__{
      state |
      id: event.id,
      email: event.email,
      name: event.name
    }
  end

  def apply(%__MODULE__{} = state, %MyApp.Events.UserStatusUpdated{} = event) do
    %__MODULE__{
      state |
      status: event.status
    }
  end
end
```