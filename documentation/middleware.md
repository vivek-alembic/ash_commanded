# Command Middleware

AshCommanded provides a middleware system that allows you to intercept and modify commands before they are dispatched, as well as process the results afterward. This is useful for implementing cross-cutting concerns such as:

- Validation
- Logging
- Authentication and authorization
- Rate limiting
- Metrics and monitoring
- Auditing
- Parameter transformation
- Error handling and standardization

## Middleware Concepts

1. **Middleware Chain**: Middleware is applied in sequence, with each middleware having the opportunity to:
   - Inspect and modify the command
   - Provide additional context
   - Short-circuit the chain by returning an error
   - Process the result after command execution

2. **Middleware Levels**: You can specify middleware at three different levels:
   - Global (application-wide)
   - Resource-level (applies to all commands in a resource)
   - Command-level (applies to a specific command)

3. **Middleware Context**: Middleware can pass information to each other using a context map.

## Using Built-in Middleware

AshCommanded includes several built-in middleware components that you can use immediately:

### LoggingMiddleware

Logs information about commands and their results:

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshCommanded.Commanded.Dsl]

  commanded do
    commands do
      # Resource-level middleware - applies to all commands
      middleware [AshCommanded.Commanded.Middleware.LoggingMiddleware]
      
      # Command-specific middleware with options
      command :register_user do
        fields [:id, :name, :email]
        middleware [
          {AshCommanded.Commanded.Middleware.LoggingMiddleware, level: :debug}
        ]
      end
    end
  end
end
```

Configuration options:
- `level`: The log level to use (`:debug`, `:info`, `:warn`, `:error`). Defaults to `:info`.
- `error_level`: The log level to use for errors. Defaults to `:error`.

### ValidationMiddleware

Validates commands before they are dispatched:

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshCommanded.Commanded.Dsl]

  commanded do
    commands do
      command :register_user do
        fields [:id, :name, :email, :age]
        
        middleware [
          {AshCommanded.Commanded.Middleware.ValidationMiddleware,
            # Require specific fields
            required: [:name, :email],
            
            # Validate field formats
            format: [
              email: ~r/@/,
              name: ~r/^[a-zA-Z\s]+$/
            ],
            
            # Custom validation function
            validate: fn command ->
              if command.age && command.age < 18 do
                {:error, "User must be at least 18 years old"}
              else
                :ok
              end
            end
          }
        ]
      end
    end
  end
end
```

Configuration options:
- `required`: List of fields that must be present and non-nil
- `format`: Map of field names to regular expressions for format validation
- `validate`: Custom validation function that takes a command and returns `:ok` or `{:error, reason}`
- `validations`: List of validations to apply (combines the above options)

## Creating Custom Middleware

You can create your own middleware by implementing the `AshCommanded.Commanded.Middleware.CommandMiddleware` behaviour or by using `AshCommanded.Commanded.Middleware.BaseMiddleware` as a starting point:

```elixir
defmodule MyApp.AuthorizationMiddleware do
  use AshCommanded.Commanded.Middleware.BaseMiddleware
  
  @impl true
  def before_dispatch(command, context, next) do
    # Extract user from context
    user = Map.get(context, :current_user)
    
    # Check authorization
    if authorized?(command, user) do
      # Continue with the command
      next.(command, context)
    else
      # Deny the command
      {:error, :unauthorized}
    end
  end
  
  @impl true
  def after_dispatch({:ok, result} = success, _command, _context) do
    # Process successful result
    success
  end
  
  def after_dispatch({:error, reason} = error, _command, _context) do
    # Process error result
    error
  end
  
  # Helper function for authorization check
  defp authorized?(command, user) do
    # Your authorization logic here...
    true
  end
end
```

## Global Middleware Configuration

You can specify global middleware that applies to all commands in your application using the application configuration:

```elixir
# In config/config.exs
config :ash_commanded, :global_middleware, [
  AshCommanded.Commanded.Middleware.LoggingMiddleware,
  {MyApp.AuthorizationMiddleware, role_check: true}
]
```

## Middleware Context

Middleware can use the context to share information:

```elixir
defmodule MyApp.TimingMiddleware do
  use AshCommanded.Commanded.Middleware.BaseMiddleware
  
  @impl true
  def before_dispatch(command, context, next) do
    # Add timestamp to context
    context_with_time = Map.put(context, :start_time, System.monotonic_time())
    
    # Call next middleware with updated context
    next.(command, context_with_time)
  end
  
  @impl true
  def after_dispatch(result, _command, context) do
    # Calculate elapsed time
    start_time = Map.get(context, :start_time)
    elapsed = System.convert_time_unit(
      System.monotonic_time() - start_time,
      :native,
      :millisecond
    )
    
    # Log timing information
    Logger.info("Command processed in #{elapsed}ms")
    
    result
  end
end
```

## Middleware Order

Middleware is applied in the following order:

1. Global middleware (from application config)
2. Resource-level middleware
3. Command-specific middleware

Within each level, middleware is applied in the order it's defined.

## Best Practices

1. **Keep Middleware Focused**: Each middleware should have a single responsibility
2. **Use Context for Communication**: Share data between middleware using the context map
3. **Handle Errors Gracefully**: Make sure to handle errors appropriately in `after_dispatch`
4. **Log Debugging Information**: Include helpful log messages for debugging
5. **Test Middleware in Isolation**: Write unit tests for your middleware
6. **Consider Performance**: Keep middleware lightweight to avoid impacting command processing time