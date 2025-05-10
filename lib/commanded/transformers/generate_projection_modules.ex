defmodule AshCommanded.Commanded.Transformers.GenerateProjectionModules do
  @moduledoc """
  Generates Elixir modules for each defined projection in the DSL.

  Each projection becomes a module with a `handle/2` function under:
  `YourApp.YourResource.Projections.<EventName>`

  ## Example Generated Module

      defmodule MyApp.Accounts.Projections.UserRegistered do
        @moduledoc "Projection for :user_registered"

        def handle(state, %{status: status}) do
          %{state | status: status}
        end
      end

  You can customize the base namespace by setting the `:projection_namespace` attribute
  on the resource module:

      @projection_namespace MyApp.Projections
  """

  @behaviour Spark.Dsl.Transformer

  alias AshCommanded.Commanded.Info

  @impl true
  def transform(resource) do
    generate_projections(resource)
    {:ok, resource}
  end

  @impl true
  def after?(_), do: false

  @impl true
  def before?(_), do: false

  @impl true
  def after_compile?, do: false

  defp generate_projections(resource) do
    Enum.each(Info.projections(resource), fn projection ->
      mod = projection_module(resource, projection.event)
      changes = Map.to_list(projection.changes)

      unless Code.ensure_loaded?(mod) do
        {:module, ^mod, _, _} =
          Module.create(
            mod,
            quote do
              @moduledoc "Projection for #{unquote(projection.event)}"

              def handle(state, event) do
                state
                |> Map.merge(%{
                  unquote_splicing(for {k, v} <- changes, do: {k, v})
                })
              end
            end,
            Macro.Env.location(__ENV__)
          )
      end
    end)
  end

  defp projection_module(resource, event) do
    custom_ns = Module.get_attribute(resource, :projection_namespace)

    base_parts =
      if custom_ns do
        Module.split(custom_ns)
      else
        Module.split(resource) |> Enum.drop(-1) |> then(&(&1 ++ ["Projections"]))
      end

    parts = base_parts ++ [Macro.camelize(to_string(event))]
    Module.concat(parts)
  end
end
