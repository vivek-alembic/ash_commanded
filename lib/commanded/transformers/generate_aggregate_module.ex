defmodule AshCommanded.Commanded.Transformers.GenerateAggregateModule do
  @moduledoc """
  Generates a Commanded Aggregate module for each resource.

  - Struct fields come from resource attributes.
  - Each event defines an `apply/2` clause updating the struct.
  """

  @behaviour Spark.Dsl.Transformer

  alias AshCommanded.Commanded.Info
  alias Ash.Resource.Info, as: ResourceInfo

  @impl true
  def transform(resource) do
    events = Info.events(resource)
    attrs = ResourceInfo.attributes(resource) |> Enum.map(& &1.name)

    mod = aggregate_module(resource)

    unless Code.ensure_loaded?(mod) do
      applies = Enum.map(events, &generate_apply_clause(&1, attrs))

      {:module, ^mod, _, _} =
        Module.create(
          mod,
          quote do
            defstruct unquote(attrs)
            unquote_splicing(applies)
          end,
          Macro.Env.location(__ENV__)
        )
    end

    {:ok, resource}
  end

  defp generate_apply_clause(event, attrs) do
    event_module = event[:event_module] || event_module_name(event)
    fields = event.fields

    bindings =
      for field <- fields do
        {field, Macro.var(field, nil)}
      end

    updates =
      for {field, var} <- bindings, field in attrs do
        {field, var}
      end

    pattern = {:%{}, [], [__struct__: event_module] ++ bindings}

    quote do
      def apply(%__MODULE__{} = state, unquote(pattern)) do
        %__MODULE__{state | unquote_splicing(updates)}
      end
    end
  end

  defp event_module_name(%{name: name}) do
    Module.concat(["Events", Macro.camelize(to_string(name))])
  end

  defp aggregate_module(resource) do
    parts = Module.split(resource)
    ns = Enum.drop(parts, -1)
    name = List.last(parts) <> "Aggregate"
    Module.concat(ns ++ [name])
  end

  @impl true
  def before?(_), do: false

  @impl true
  def after?(_), do: false

  @impl true
  def after_compile?, do: false
end
