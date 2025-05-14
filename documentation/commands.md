# Commands

Commands in AshCommanded represent intentions to change the state of your application. They are the input side of the CQRS pattern.

## Defining Commands

Commands are defined in the `commanded` DSL extension for Ash resources:

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
    commands do
      command :register_customer do
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
defmodule ECommerce.Commands.RegisterCustomer do
  @moduledoc """
  Command for registering a new customer
  """

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
defmodule AshCommanded.Commanded.CommandHandlers.CustomerHandler do
  @behaviour Commanded.Commands.Handler

  def handle(%ECommerce.Commands.RegisterCustomer{} = cmd, _metadata) do
    Ash.run_action(ECommerce.Customer, :register_customer, Map.from_struct(cmd))
  end

  def handle(%ECommerce.Commands.UpdateStatus{} = cmd, _metadata) do
    Ash.run_action(ECommerce.Customer, :update_status, Map.from_struct(cmd))
  end
end
```