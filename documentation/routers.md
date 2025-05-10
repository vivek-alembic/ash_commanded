# Router Generation

AshCommanded automatically generates [Commanded Routers](https://hexdocs.pm/commanded/commands.html) for dispatching commands to the appropriate handlers and aggregates based on your domain structure.

## Domain-specific Routers

For each Ash.Domain containing resources with the AshCommanded.Commanded.Dsl extension, a domain-specific router is generated:

```elixir
defmodule MyApp.MyDomain.Router do
  use Commanded.Commands.Router

  # For each resource in the domain
  identify MyApp.ResourceAggregate, by: :id
  dispatch [MyApp.Commands.CreateResource, MyApp.Commands.UpdateResource], to: MyApp.ResourceAggregate
end
```

These domain routers handle command routing within a specific domain context.

## Main Application Router

AshCommanded also generates a main application router at `AshCommanded.Router`. The behavior of this router depends on the domain structure:

### Single Domain Setup

For applications with a single domain, the main router directly routes commands to aggregates:

```elixir
defmodule AshCommanded.Router do
  use Commanded.Commands.Router

  # Direct command routing for all resources
  identify MyApp.ResourceAggregate, by: :id
  dispatch [MyApp.Commands.CreateResource, MyApp.Commands.UpdateResource], to: MyApp.ResourceAggregate
end
```

### Multiple Domain Setup

For applications with multiple domains, the main router forwards commands to the appropriate domain router:

```elixir
defmodule AshCommanded.Router do
  use Commanded.Commands.Router

  # Forward to domain routers
  forward MyApp.Domain1.Router
  forward MyApp.Domain2.Router
end
```

## Command Dispatching

With these routers in place, you can dispatch commands using:

```elixir
command = %MyApp.Commands.CreateResource{id: "123", name: "Example"}
AshCommanded.Router.dispatch(command)
```

The command will be routed to the appropriate aggregate and handler based on the command type and the resource's identity.

## Identity Resolution

By default, the router uses the resource's primary identity key or the specified `identity_field` in the command definition.

```elixir
commanded do
  commands do
    command :create_resource do
      fields([:id, :name])
      identity_field(:id)  # Explicitly specify the identity field
    end
  end
end
```

If no identity field is specified, the router will try to use:
1. The first field from the resource's primary identity
2. The `:id` field as a fallback