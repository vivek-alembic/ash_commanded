# Parameter Transformation and Validation

AshCommanded provides powerful parameter transformation and validation capabilities for command handling, allowing you to:

1. Transform command fields before they're sent to actions
2. Validate command parameters to ensure they meet specific criteria
3. Add computed fields based on input parameters
4. Apply complex, multi-step transformations to command data

These features enhance the integration between commands and Ash actions, making it easier to map command fields to action parameters and to ensure that commands meet your business rules.

## Parameter Transformation

Parameter transformation allows you to modify command parameters before they're sent to Ash actions. This is useful for:

- Renaming fields to match action expectations
- Type conversion (e.g., string to integer)
- Computing new fields
- Setting default values
- Applying complex transformations

### Basic Usage

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshCommanded.Commanded.Dsl]

  commanded do
    commands do
      command :register_user do
        fields [:id, :name, :email, :birthdate]
        
        transform_params do
          # Map a field from one name to another
          map :name, to: :full_name
          
          # Cast a field to a specific type
          cast :birthdate, :date
          
          # Compute a new field
          compute :display_name, fn params ->
            "#{params.full_name} <#{params.email}>"
          end
          
          # Transform a field value
          transform :email, &String.downcase/1
          
          # Set default values
          default :status, "active"
          default :created_at, &DateTime.utc_now/0
          
          # Custom transformation for all params
          custom fn params ->
            # Additional custom transformations...
            params
          end
        end
      end
    end
  end
end
```

### Transformation Types

| Transformation | Description | Example |
|----------------|-------------|---------|
| `map` | Renames a field | `map :name, to: :full_name` |
| `cast` | Converts a field to a specific type | `cast :age, :integer` |
| `compute` | Creates a new field using a function | `compute :display_name, fn p -> "#{p.name}" end` |
| `transform` | Applies a function to a field | `transform :email, &String.downcase/1` |
| `default` | Sets a default value if the field is nil | `default :status, "active"` |
| `custom` | Applies a function to the entire params map | `custom fn p -> Map.put(p, :key, "value") end` |

### Type Casting

AshCommanded supports casting fields to the following types:

- `:string`
- `:integer`
- `:float`
- `:boolean`
- `:date`
- `:datetime`
- `:atom`
- `:list`
- `:map`

For example:

```elixir
transform_params do
  # Convert string to integer
  cast :age, :integer
  
  # Convert string to datetime
  cast :created_at, :datetime
  
  # Convert string to boolean
  cast :active, :boolean
end
```

## Parameter Validation

Parameter validation ensures that command data meets specific criteria before processing. This allows you to:

- Ensure required fields are present
- Validate field formats (e.g., email, date)
- Check value ranges (e.g., minimum/maximum)
- Apply domain-specific validation rules
- Prevent invalid commands from being processed

### Basic Usage

```elixir
defmodule MyApp.User do
  use Ash.Resource,
    extensions: [AshCommanded.Commanded.Dsl]

  commanded do
    commands do
      command :register_user do
        fields [:id, :name, :email, :age, :password]
        
        validate_params do
          # Type validation
          validate :name, type: :string
          validate :email, type: :string
          validate :age, type: :integer
          
          # Format validation
          validate :email, format: ~r/^[^\s]+@[^\s]+\.[^\s]+$/
          
          # Range validation
          validate :age, min: 18, max: 120
          
          # Length validation
          validate :name, min_length: 2, max_length: 100
          
          # Custom validation
          validate :password, fn value ->
            cond do
              String.length(value) < 8 ->
                {:error, "Password must be at least 8 characters"}
              not String.match?(value, ~r/[A-Z]/) ->
                {:error, "Password must contain an uppercase letter"}
              not String.match?(value, ~r/[0-9]/) ->
                {:error, "Password must contain a number"}
              true ->
                :ok
            end
          end
        end
      end
    end
  end
end
```

### Validation Types

| Validation | Description | Example |
|------------|-------------|---------|
| `type` | Checks the field's type | `validate :age, type: :integer` |
| `format` | Validates against a regular expression | `validate :email, format: ~r/@/` |
| `min`/`max` | Checks numeric range | `validate :age, min: 18, max: 120` |
| `min_length`/`max_length` | Checks string length | `validate :name, min_length: 2` |
| `min_items`/`max_items` | Checks list item count | `validate :tags, min_items: 1` |
| `one_of` | Checks value against a list | `validate :role, one_of: [:user, :admin]` |
| `subset_of` | For lists, checks all values | `validate :roles, subset_of: [:user, :admin]` |
| Custom function | Applies arbitrary validation logic | `validate :field, fn value -> ... end` |

### Combining Multiple Validations

You can apply multiple validations to a single field:

```elixir
validate_params do
  validate :password do
    min_length 8
    format ~r/[A-Z]/  # Contains uppercase letter
    format ~r/[a-z]/  # Contains lowercase letter
    format ~r/[0-9]/  # Contains number
    format ~r/[^A-Za-z0-9]/  # Contains special character
  end
end
```

## Integration with Command Middleware

Both parameter transformation and validation can also be implemented as middleware. The built-in `ValidationMiddleware` provides similar functionality to the `validate_params` DSL:

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
            required: [:name, :email, :age],
            format: [email: ~r/@/],
            validate: fn command ->
              if command.age < 18 do
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

## Benefits Over Basic Mapping

The parameter transformation and validation system provides several advantages over basic field mapping:

1. **Type Safety**: Automatic type conversion ensures values match expected types
2. **Data Normalization**: Fields can be consistently transformed (e.g., lowercase emails)
3. **Computation**: Derived fields can be calculated based on input parameters
4. **Validation**: Problems are caught early in the command lifecycle
5. **Security**: Input can be sanitized and validated before processing
6. **Default Values**: Missing or nil values can be automatically populated
7. **Contextual Processing**: Command parameters can be transformed based on other parameters

By using these features, you can create a more robust integration between your commands and Ash actions, with clear validation rules and transformation logic.