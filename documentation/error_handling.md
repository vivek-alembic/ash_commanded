# Error Handling in AshCommanded

This document explains the error handling system in AshCommanded, which provides standardized, structured error reports and consistent error handling across the entire framework.

## Overview

AshCommanded provides a standardized approach to error handling through the `AshCommanded.Commanded.Error` module. This system ensures that:

1. Errors have a consistent structure across the framework
2. Error messages are user-friendly and informative
3. Developers can easily identify the source and context of errors
4. Errors can be properly formatted for display to users
5. Errors from different sources (Ash, Commanded) are normalized to a common format

## Error Structure

All errors in AshCommanded are represented using the `AshCommanded.Commanded.Error` struct, which has the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `type` | atom | The category of error (e.g., `:validation_error`, `:command_error`) |
| `message` | string | A human-readable error message |
| `path` | list | Path to the error in a data structure (for nested errors) |
| `field` | atom | The specific field that caused the error (if applicable) |
| `value` | any | The value that caused the error (if applicable) |
| `context` | map | Additional contextual information about the error |

## Error Types

The following error types are used throughout AshCommanded:

| Type | Description | Common Uses |
|------|-------------|-------------|
| `:validation_error` | Error validating command parameters | Parameter validation failures |
| `:transformation_error` | Error transforming command parameters | Type casting failures, computation errors |
| `:command_error` | Error related to command structure or processing | Missing required fields, invalid command structure |
| `:aggregate_error` | Error in aggregate processing | Command execution failures in aggregates |
| `:dispatch_error` | Error dispatching a command | Router errors, event store errors |
| `:action_error` | Error executing an Ash action | Resource action failures |
| `:projection_error` | Error applying a projection | Event handling errors in projectors |

## Creating Errors

You can create errors using the constructor functions in the `AshCommanded.Commanded.Error` module:

```elixir
# General constructor
Error.new(:validation_error, "Value must be positive", field: :age, value: -5)

# Type-specific constructors
Error.validation_error("Value must be positive", field: :age, value: -5)
Error.transformation_error("Failed to cast to integer", field: :age, value: "abc")
Error.command_error("Missing required field", field: :id)
Error.aggregate_error("Aggregate not found", context: %{aggregate_id: "123"})
Error.action_error("Failed to execute action", context: %{action: :create_user})
```

## Error Normalization

AshCommanded automatically normalizes errors from different sources into the standard format. This is handled through the `normalize_error/1` and `normalize_errors/1` functions:

```elixir
# Convert an Ash error to AshCommanded format
ash_error = %Ash.Error.Invalid{errors: [%Ash.Error.Changes.InvalidAttribute{field: :name, message: "can't be blank"}]}
normalized_error = Error.normalize_error(ash_error)

# Convert a Commanded error to AshCommanded format
commanded_error = %Commanded.Aggregates.ExecutionError{message: "Failed to execute command"}
normalized_error = Error.normalize_error(commanded_error)

# Normalize a list of mixed errors
errors = [ash_error, commanded_error, "Simple string error"]
normalized_errors = Error.normalize_errors(errors)
```

## Error Formatting

To display errors in a human-readable format, use the `format/1` function:

```elixir
error = Error.validation_error("Value must be positive", field: :age, value: -5)
formatted = Error.format(error)
# => "Validation error: Value must be positive (field: age, value: -5)"
```

## Error Handling in Components

### Parameter Validation

The parameter validator uses standardized error handling:

```elixir
params = %{name: "John", email: "invalid-email", age: 15}
validations = [
  {:validate, :name, [min_length: 5]},
  {:validate, :email, [format: ~r/@.*\./]},
  {:validate, :age, [min: 18]}
]

case AshCommanded.Commanded.ParameterValidator.validate_params(params, validations) do
  :ok ->
    # Proceed with valid parameters
    
  {:error, errors} ->
    # Handle validation errors
    formatted_errors = Enum.map(errors, &Error.format/1)
    IO.puts("Validation failed: #{Enum.join(formatted_errors, ", ")}")
end
```

### Command Action Mapper

The command action mapper handles errors throughout the command execution process:

```elixir
result = AshCommanded.Commanded.CommandActionMapper.map_to_action(
  command,
  MyApp.User,
  :create_user,
  transforms: transforms,
  validations: validations
)

case result do
  {:ok, record} ->
    # Command executed successfully
    
  {:error, errors} when is_list(errors) ->
    # Multiple errors occurred
    formatted_errors = Enum.map(errors, &Error.format/1)
    IO.puts("Command failed: #{Enum.join(formatted_errors, ", ")}")
    
  {:error, error} ->
    # A single error occurred
    IO.puts("Command failed: #{Error.format(error)}")
end
```

### Aggregate Error Handling

The generated aggregate modules include standardized error handling:

```elixir
def execute(%__MODULE__{} = aggregate, %MyApp.Commands.RegisterUser{} = command) do
  try do
    # Command handling logic...
  rescue
    e in _ ->
      {:error, Error.aggregate_error("Error executing command: #{Exception.message(e)}", 
        context: %{command: command.__struct__, error: inspect(e)})}
  end
end
```

## Extracting Errors from Results

To extract errors from command results, use the `errors_from_result/1` function:

```elixir
result = AshCommanded.Commands.RegisterUser.execute(command)

errors = Error.errors_from_result(result)
if Enum.empty?(errors) do
  IO.puts("Command succeeded!")
else
  formatted_errors = Enum.map(errors, &Error.format/1)
  IO.puts("Command failed: #{Enum.join(formatted_errors, ", ")}")
end
```

## Best Practices

1. **Always use standardized errors**: Use the `Error` module for all error creation rather than returning raw atoms or strings.

2. **Include contextual information**: When creating errors, include relevant context such as field names, values, and additional contextual data.

3. **Handle errors gracefully**: Design your code to handle errors properly, using pattern matching to extract error information.

4. **Use proper error types**: Choose the appropriate error type for each situation to help with debugging and error handling.

5. **Format errors for display**: When displaying errors to users, use the `format/1` function to create readable error messages.

## Integration with Ash Framework

AshCommanded automatically converts Ash errors to the standardized format, making it easier to integrate with existing Ash resources:

```elixir
case AshCommanded.Commanded.CommandActionMapper.map_to_action(command, resource, action_name) do
  {:ok, result} ->
    # Success
    
  {:error, errors} ->
    # Both Ash errors and AshCommanded errors will be properly formatted
    formatted_errors = Enum.map(Error.normalize_errors(errors), &Error.format/1)
end
```