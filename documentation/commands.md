# Commands

Commands in AshCommanded represent intentions to change the state of your application. They are the input side of the CQRS pattern.

## Defining Commands

Commands are defined in the `commanded` DSL extension for Ash resources:

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
    commands do
      command :register_user do
        fields([:id, :email, :name])
        identity_field(:id)
      end

      command :update_status do
        fields([:id, :status])
      end
    end
  end
end
```

## Command Options

Each command can have the following options:

- `fields`: List of fields the command accepts
- `identity_field`: Field used to identify the aggregate instance
- `autogenerate_handler?`: Whether to generate a command handler (default: true)
- `handler_name`: Custom name for the handler function (default: :handle)
- `action`: Ash action to invoke when handling the command (defaults to command name)
- `command_name`: Override the generated command module name

## Generated Command Modules

For each command, AshCommanded generates a command module:

```elixir
defmodule MyApp.Commands.RegisterUser do
  @moduledoc """
  Command for registering a new user
  """

  use Ash.Resource.Commands.Command

  @type t :: %__MODULE__{
    id: String.t(),
    email: String.t(),
    name: String.t()
  }

  defstruct [:id, :email, :name]
end
```

## Command Handlers

AshCommanded automatically generates command handlers that invoke the corresponding Ash actions:

```elixir
defmodule AshCommanded.Commanded.CommandHandlers.UserHandler do
  @behaviour Commanded.Commands.Handler

  def handle(%MyApp.Commands.RegisterUser{} = cmd, _metadata) do
    Ash.run_action(MyApp.User, :register_user, Map.from_struct(cmd))
  end

  def handle(%MyApp.Commands.UpdateStatus{} = cmd, _metadata) do
    Ash.run_action(MyApp.User, :update_status, Map.from_struct(cmd))
  end
end
```