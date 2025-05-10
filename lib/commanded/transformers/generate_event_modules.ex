defmodule AshCommanded.Commanded.Transformers.GenerateEventModules do
  @moduledoc """
  Generates Elixir modules for each defined event in the DSL.

  Each event becomes a module with a `defstruct` and typespec under:
  `YourApp.YourResource.Events.<EventName>`

  ## Example Generated Module

      defmodule MyApp.Accounts.Events.UserRegistered do
        @moduledoc "Event module for :user_registered"
        defstruct [:id, :email, :name]

        @type t :: %__MODULE__{
                id: term(),
                email: term(),
                name: term()
              }
      end

  You can customize the base namespace by setting the `@event_namespace` module attribute
  on the resource module, or override per-event using:

  - `event_name: :CustomName` to control the generated module name
  - `autogenerate?: false` to skip code generation for that event
  """

  @behaviour Spark.Dsl.Transformer

  alias AshCommanded.Commanded.Info

  @impl true
  def transform(resource) do
    events = Info.events(resource) |> Enum.reject(&(&1[:autogenerate?] == false))

    validate_unique_event_modules!(resource, events)
    generate_events(resource, events)

    {:ok, resource}
  end

  @impl true
  def after?(_), do: false

  @impl true
  def before?(_), do: false

  @impl true
  def after_compile?, do: false

  defp validate_unique_event_modules!(resource, events) do
    mods = Enum.map(events, &event_module(resource, &1))
    dups = mods -- Enum.uniq(mods)

    if dups != [] do
      raise Spark.Error.DslError,
        path: [:commanded, :events],
        message: "Duplicate event module names detected: #{inspect(Enum.uniq(dups))}"
    end
  end

  defp generate_events(resource, events) do
    Enum.each(events, fn event ->
      mod = event_module(resource, event)
      fields = event.fields

      unless Code.ensure_loaded?(mod) do
        {:module, ^mod, _, _} =
          Module.create(
            mod,
            quote do
              @moduledoc "Event module for #{unquote(event.name)}"
              defstruct unquote(fields)

              @type t :: %__MODULE__{
                      unquote_splicing(for field <- fields, do: {field, quote(do: term())})
                    }
            end,
            Macro.Env.location(__ENV__)
          )
      end
    end)
  end

  defp event_module(resource, %{name: name} = event) do
    ns =
      case Module.get_attribute(resource, :event_namespace) do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          Module.concat(parts ++ ["Events"])

        namespace ->
          namespace
      end

    name_atom = event[:event_name] || Macro.camelize(to_string(name))
    Module.concat(ns, name_atom)
  end
end
