# Context Propagation

AshCommanded provides comprehensive context propagation between commands and actions, allowing for rich information sharing throughout the command execution pipeline.

## Overview

Context propagation enables:

1. Access to the aggregate state within action execution
2. Access to the original command in actions
3. Metadata sharing between commands and actions
4. Custom static context values
5. Flexible context key prefixing to prevent collisions

This mechanism ensures that actions have full access to the command execution context, improving traceability and enabling more sophisticated behavior.

## Configuring Context Propagation

Context propagation can be configured at the command level in the `commanded` DSL:

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshCommanded.Commanded.Dsl]

  commanded do
    commands do
      command :register_user do
        fields [:id, :email, :name]
        identity_field :id
        
        # Context propagation options
        include_aggregate? true 
        include_command? true
        include_metadata? true
        context_prefix :cmd
        static_context %{source: :web_api}
      end
    end
  end
end
```

## Context Options

The following options control context propagation:

- `include_aggregate?` - Whether to include the aggregate state in the action context (default: `true`)
- `include_command?` - Whether to include the command struct in the action context (default: `true`)
- `include_metadata?` - Whether to include command metadata in the action context (default: `true`)
- `context_prefix` - An optional prefix for context keys to prevent collisions (default: `nil`)
- `static_context` - Static context values to include in every action execution (default: `%{}`)

## Context Structure

By default, the following context keys are included:

- `:aggregate` - The current state of the aggregate
- `:command` - The command being executed
- `:metadata` - Command metadata (if present)

When a `context_prefix` is specified, the keys become:

- `:"prefix.aggregate"` - The current state of the aggregate
- `:"prefix.command"` - The command being executed
- `:"prefix.metadata"` - Command metadata (if present)

Any values in `static_context` are merged directly into the context map.

## Accessing Context in Actions

Within your Ash actions, you can access the context as follows:

```elixir
defmodule MyApp.UserActions do
  def create_user(changeset) do
    # Get context from the changeset
    context = Ash.Changeset.get_context(changeset)
    
    # Access aggregate state (if included)
    aggregate = Map.get(context, :aggregate)
    
    # Access command (if included)
    command = Map.get(context, :command)
    
    # Access metadata (if included)
    metadata = Map.get(context, :metadata)
    
    # Access static context values
    source = Map.get(context, :source)
    
    # Use context data in your action logic
    # ...
    
    changeset
  end
end
```

With a `context_prefix`, you would access the keys with the prefix:

```elixir
# With context_prefix: :cmd
aggregate = Map.get(context, :"cmd.aggregate")
command = Map.get(context, :"cmd.command")
metadata = Map.get(context, :"cmd.metadata")
```

## Context and Event Generation

When commands are processed, the action result can influence the generated event:

```elixir
defmodule MyApp.UserActions do
  def create_user(changeset) do
    # Return additional data to include in the event
    # This will be merged with the command fields
    {:ok, %{registered_at: DateTime.utc_now()}}
  end
end
```

The additional map returned by the action will be merged with the command fields when generating the event, allowing for dynamic event enrichment.

## Context in Middleware

Command middleware also has access to the context, enabling powerful pattern like:

- Audit logging using command, metadata, and aggregate state
- Authorization based on command and metadata
- Dynamic command transformation based on context
- Context-aware validation

## Example: Using Context in Practice

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshCommanded.Commanded.Dsl]

  attributes do
    uuid_primary_key :id
    attribute :email, :string
    attribute :name, :string
    attribute :status, :string
    attribute :created_at, :utc_datetime
  end

  actions do
    create :create do
      accept [:id, :email, :name]
      change create_timestamp()
    end
    
    update :update_email do
      accept [:email]
      change update_timestamp()
    end
  end
  
  # Action helpers using context
  defp create_timestamp(changeset) do
    context = Ash.Changeset.get_context(changeset)
    source = Map.get(context, :source, :unknown)
    
    changeset
    |> Ash.Changeset.change_attribute(:created_at, DateTime.utc_now())
    |> Ash.Changeset.put_context(:creation_source, source)
  end
  
  defp update_timestamp(changeset) do
    context = Ash.Changeset.get_context(changeset)
    command = Map.get(context, :command)
    
    timestamp = DateTime.utc_now()
    
    changeset
    |> Ash.Changeset.change_attribute(:updated_at, timestamp)
    |> Ash.Changeset.put_metadata(:last_change, %{
      field: :email,
      from: Map.get(context.aggregate || %{}, :email),
      to: command.email,
      timestamp: timestamp
    })
  end
  
  commanded do
    commands do
      command :register_user do
        fields [:id, :email, :name]
        identity_field :id
        action :create
        static_context %{source: :registration_form}
      end
      
      command :update_email do
        fields [:id, :email]
        identity_field :id
        action :update_email
        context_prefix :user
      end
    end
    
    events do
      event :user_registered do
        fields [:id, :email, :name, :created_at]
      end
      
      event :email_updated do
        fields [:id, :email, :updated_at]
      end
    end
  end
end
```

## Benefits of Context Propagation

1. **Richer Domain Logic** - Actions can incorporate command and aggregate information
2. **Improved Auditing** - Full command context for better traceability
3. **Better Event Generation** - Events can include action-specific data
4. **Reduced Duplication** - No need to repeat data already in commands or aggregates
5. **Context-Aware Behavior** - Actions can adapt based on context information

## Best Practices

1. Use `context_prefix` when integrating with other extensions to avoid key collisions
2. Keep the `static_context` map small and focused on truly static values
3. Use `include_aggregate?` and `include_command?` selectively for large objects
4. Document which context keys your actions depend on
5. Consider using middleware for cross-cutting concerns rather than action-specific context handling