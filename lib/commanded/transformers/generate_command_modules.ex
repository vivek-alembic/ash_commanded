defmodule AshCommanded.Commanded.Transformers.GenerateCommandModules do
  @moduledoc """
  Generates Elixir modules for each defined command in the DSL.

  Each command becomes a module with a `defstruct` and typespec under:
  `YourApp.YourResource.Commands.<CommandName>`

  ## Example Generated Module

      defmodule MyApp.Accounts.Commands.RegisterUser do
        @moduledoc "Command module for :register_user"
        @enforce_keys [:id, :email, :name]
        defstruct id: nil, email: nil, name: nil

        @type t :: %__MODULE__{
                id: term(),
                email: term(),
                name: term()
              }
      end

  You can customize the base namespace by setting the `@command_namespace` module attribute
  on the resource module, or override per-command using:

  - `command_name: :CustomName` to control the generated module name
  - `autogenerate?: false` to skip code generation for that command
  """

  @behaviour Spark.Dsl.Transformer

  alias AshCommanded.Commanded.Info

  @impl true
  def transform(resource) do
    commands =
      Info.commands(resource)
      |> Enum.reject(&(&1[:autogenerate?] == false))

    validate_unique_command_modules!(resource, commands)

    Enum.each(commands, fn command ->
      mod = command_module(resource, command)
      fields = command.fields

      struct_fields = for field <- fields, do: {field, nil}
      typespec_fields = for field <- fields, do: {field, quote(do: term())}

      unless Code.ensure_loaded?(mod) do
        {:module, ^mod, _, _} =
          Module.create(
            mod,
            quote do
              @moduledoc "Command module for #{unquote(command.name)}"

              @enforce_keys unquote(fields)
              defstruct unquote(struct_fields)

              @type t :: %__MODULE__{
                      unquote_splicing(typespec_fields)
                    }
            end,
            Macro.Env.location(__ENV__)
          )
      end
    end)

    {:ok, resource}
  end

  @impl true
  def after?(_), do: false

  @impl true
  def before?(_), do: false

  @impl true
  def after_compile?, do: false

  defp validate_unique_command_modules!(resource, commands) do
    mods =
      commands
      |> Enum.map(&command_module(resource, &1))

    dups = mods -- Enum.uniq(mods)

    if dups != [] do
      raise Spark.Error.DslError,
        path: [:commanded, :commands],
        message: "Duplicate command module names detected: #{inspect(Enum.uniq(dups))}"
    end
  end

  defp command_module(resource, %{name: name} = command) do
    custom_ns = Module.get_attribute(resource, :command_namespace)

    base_parts =
      if custom_ns do
        Module.split(custom_ns)
      else
        Module.split(resource) |> Enum.drop(-1) |> then(&(&1 ++ ["Commands"]))
      end

    name_atom = command[:command_name] || Macro.camelize(to_string(name))
    Module.concat(base_parts ++ [name_atom])
  end
end
