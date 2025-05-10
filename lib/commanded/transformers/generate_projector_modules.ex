defmodule AshCommanded.Commanded.Transformers.GenerateProjectorModules do
  @moduledoc """
  Generates Commanded projector modules from Ash projections.

  Each resource gets one projector module, with a `project/3` clause per defined projection.
  By default, it calls the Ash `update` action with changes, but users can specify a custom action.
  The projector module name can be overridden with `:projector_name` in the projection DSL.
  Generation can be disabled with `autogenerate?: false` in the projection DSL.
  """

  @behaviour Spark.Dsl.Transformer

  alias AshCommanded.Commanded.Info

  @impl true
  def transform(resource) do
    projections =
      Info.projections(resource)
      |> Enum.reject(&(&1[:autogenerate?] == false))

    validate_consistent_projector_name!(projections)

    unless projections == [] do
      create_projector_module(resource, projections)
    end

    {:ok, resource}
  end

  @impl true
  def after?(_), do: false

  @impl true
  def before?(_), do: false

  @impl true
  def after_compile?, do: false

  defp validate_consistent_projector_name!(projections) do
    names =
      projections
      |> Enum.map(& &1[:projector_name])
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    if length(names) > 1 do
      raise Spark.Error.DslError,
        path: [:commanded, :projections],
        message:
          "Multiple conflicting projector_name values found: #{inspect(names)}. Only one is allowed per resource."
    end
  end

  defp create_projector_module(resource, projections) do
    mod = projector_module(resource, projections)

    unless Code.ensure_loaded?(mod) do
      projections_ast =
        Enum.map(projections, fn proj ->
          action = proj[:action] || :update
          changes = proj.changes
          event_mod = event_module(resource, proj.event)

          quoted_changes =
            for {k, v} <- changes do
              {k, quote(do: Map.get(event, unquote(v)))}
            end

          quote do
            project(%unquote(event_mod){} = event, _metadata, fn _context ->
              Ash.Changeset.new(unquote(resource), event)
              |> Ash.Changeset.for_action(unquote(action), %{unquote_splicing(quoted_changes)})
              |> apply_action_fn(unquote(action))
            end)
          end
        end)

      {:module, ^mod, _, _} =
        Module.create(
          mod,
          quote do
            use Commanded.Projections.Ecto, name: unquote(to_string(mod))

            unquote_splicing(projections_ast)

            defp apply_action_fn(:create), do: &Ash.create/1
            defp apply_action_fn(:update), do: &Ash.update/1
            defp apply_action_fn(:destroy), do: &Ash.destroy/1
            defp apply_action_fn(action), do: raise("Unsupported action: #{inspect(action)}")
          end,
          Macro.Env.location(__ENV__)
        )
    end
  end

  defp projector_module(resource, projections) do
    ns =
      case Module.get_attribute(resource, :projector_namespace) do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          Module.concat(parts ++ ["Projectors"])

        namespace ->
          namespace
      end

    name =
      Enum.find_value(projections, fn p -> p[:projector_name] end) ||
        List.last(Module.split(resource)) <> "Projector"

    Module.concat(ns, name)
  end

  defp event_module(resource, event_name) do
    ns =
      case Module.get_attribute(resource, :event_namespace) do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          Module.concat(parts ++ ["Events"])

        namespace ->
          namespace
      end

    Module.concat(ns, Macro.camelize(to_string(event_name)))
  end
end
