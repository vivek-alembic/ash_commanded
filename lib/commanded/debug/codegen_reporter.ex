defmodule AshCommanded.Commanded.Debug.CodegenReporter do
  @moduledoc """
  Produces a summary of generated modules and DSL info for a given resource.
  Useful for debugging or introspection.

  ## Example

      iex> AshCommanded.Commanded.Debug.CodegenReporter.print(MyApp.Accounts.User)
      === Codegen Summary for MyApp.Accounts.User ===
      == Commands
        • :register_user (command) -> MyApp.Accounts.Commands.RegisterUser ✓
      == Events
        • :user_registered (event) -> MyApp.Accounts.Events.UserRegistered ✓
      == Projections
        • :user_registered (projection) -> MyApp.Accounts.Projections.UserRegistered ✓
  """

  alias AshCommanded.Commanded.Info

  def print(resource) do
    IO.puts("""
    === Codegen Summary for #{inspect(resource)} ===
    """)

    print_commands(resource)
    print_events(resource)
    print_projections(resource)
  end

  defp print_commands(resource) do
    IO.puts("== Commands")

    Enum.each(Info.commands(resource), fn cmd ->
      mod = module_for(resource, cmd.name, :command)
      print_module(:command, cmd.name, mod)
    end)
  end

  defp print_events(resource) do
    IO.puts("== Events")

    Enum.each(Info.events(resource), fn evt ->
      mod = module_for(resource, evt.name, :event)
      print_module(:event, evt.name, mod)
    end)
  end

  defp print_projections(resource) do
    IO.puts("== Projections")

    Enum.each(Info.projections(resource), fn proj ->
      mod = module_for(resource, proj.event, :projection)
      print_module(:projection, proj.event, mod)
    end)
  end

  defp print_module(type, name, mod) do
    status = if Code.ensure_loaded?(mod), do: "✓", else: "✗ MISSING"
    IO.puts("  • #{inspect(name)} (#{type}) -> #{inspect(mod)} #{status}")
  end

  defp module_for(resource, name, :command) do
    ns =
      case Module.get_attribute(resource, :command_namespace) do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          Module.concat(parts ++ ["Commands"])

        namespace ->
          namespace
      end

    Module.concat(ns, Macro.camelize(to_string(name)))
  end

  defp module_for(resource, name, :event) do
    ns =
      case Module.get_attribute(resource, :event_namespace) do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          Module.concat(parts ++ ["Events"])

        namespace ->
          namespace
      end

    Module.concat(ns, Macro.camelize(to_string(name)))
  end

  defp module_for(resource, name, :projection) do
    ns =
      case Module.get_attribute(resource, :projection_namespace) do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          Module.concat(parts ++ ["Projections"])

        namespace ->
          namespace
      end

    Module.concat(ns, Macro.camelize(to_string(name)))
  end
end
