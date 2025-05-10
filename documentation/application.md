# Commanded Application

AshCommanded can automatically generate a Commanded application module to simplify working with routers and projectors.

## Domain Application Configuration

Configure the Commanded application in your domain:

```elixir
defmodule MyApp.Domain do
  use Ash.Domain

  resources do
    resource MyApp.User
    resource MyApp.Product
  end

  commanded do
    application do
      # Required: OTP application name for configuration
      otp_app :my_app
      
      # Optional: Custom application module name (default: {Domain}CommandedApp)
      name MyApp.CommandedApplication
      
      # Optional: Event store adapter (defaults to nil, which will use EventStore)
      event_store Commanded.EventStore.Adapters.InMemory
      
      # Optional: PubSub adapter for broadcasting events
      pubsub MyApp.PubSub
      
      # Optional: Process registry (defaults to Commanded.Registration.SwarmRegistry)
      registry Commanded.Registration.LocalRegistry
      
      # Optional: Enable aggregate snapshotting
      snapshotting true
      
      # Optional: Take a snapshot every n events
      snapshot_every 100
      
      # Optional: Snapshot version (for upgrades)
      snapshot_version 1
      
      # Optional: Whether to include a supervisor for projectors (default: true)
      include_supervisor? true
    end
  end
end
```

## Generated Application Module

The DSL will generate an application module using the configuration:

```elixir
defmodule MyApp.CommandedApplication do
  use Commanded.Application,
    otp_app: :my_app,
    event_store: Commanded.EventStore.Adapters.InMemory,
    pubsub: MyApp.PubSub,
    registry: Commanded.Registration.LocalRegistry,
    snapshotting: true,
    snapshot_every: 100,
    snapshot_version: 1

  router MyApp.Domain.Router

  # Supervision for projectors
  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]},
      type: :supervisor,
      restart: :permanent,
      shutdown: 5000
    }
  end
  
  def start_link(opts \\ []) do
    import Supervisor.Spec, warn: false
    
    children = [
      MyApp.Projectors.UserProjector,
      MyApp.Projectors.ProductProjector
    ]
    
    opts = Keyword.merge([strategy: :one_for_one, name: __MODULE__.Supervisor], opts)
    Supervisor.start_link(children, opts)
  end
end
```

## Supervising the Application

Add the generated application to your main application's supervision tree:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Other children...
      
      # Start the Commanded application with all projectors
      MyApp.CommandedApplication
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Disabling Projector Supervision

You can disable the automatic projector supervision by setting `include_supervisor?: false`:

```elixir
commanded do
  application do
    otp_app :my_app
    include_supervisor? false
  end
end
```

This will generate an application module without supervision functions, allowing you to manually supervise projectors in your application's supervision tree:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Start the Commanded application
      MyApp.CommandedApplication,
      
      # Manually start projectors
      MyApp.Projectors.UserProjector,
      MyApp.Projectors.ProductProjector
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```