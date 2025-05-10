defmodule AshCommanded.Commanded.Transformers.GenerateCommandHandlerModules do
  @moduledoc """
  Generates Commanded command handler modules for each resource.

  Each resource gets a command handler module under `AshCommanded.Commanded.CommandHandlers`,
  with one `handle/2` clause per defined command. The command handlers invoke the
  corresponding Ash action using `Ash.run_action/2` for the resource.

  Handler clauses can be disabled using `autogenerate_handler?: false`, and
  `handler_name:` can be used to customize the function clause name.
  """

  @behaviour Spark.Dsl.Transformer

  alias AshCommanded.Commanded.Info

  @impl true
  def transform(resource) do
    commands =
      Info.commands(resource)
      |> Enum.reject(&(&1[:autogenerate_handler?] == false))

    unless commands == [] do
      create_handler_module(resource, commands)
    end

    {:ok, resource}
  end

  @impl true
  def after?(_), do: false

  @impl true
  def before?(_), do: false

  @impl true
  def after_compile?, do: false

  defp create_handler_module(resource, commands) do
    mod = handler_module(resource)

    unless Code.ensure_loaded?(mod) do
      commands_ast =
        Enum.map(commands, fn command ->
          action = command[:action] || command[:name]
          clause_name = command[:handler_name] || :handle
          command_mod = command_module(resource, command)

          quote do
            def unquote(clause_name)(%unquote(command_mod){} = cmd, _metadata) do
              Ash.run_action(unquote(resource), unquote(action), Map.from_struct(cmd))
            end
          end
        end)

      {:module, ^mod, _, _} =
        Module.create(
          mod,
          quote do
            @behaviour Commanded.Commands.Handler
            unquote_splicing(commands_ast)
          end,
          Macro.Env.location(__ENV__)
        )
    end
  end

  defp handler_module(resource) do
    ns = Module.concat([AshCommanded.Commanded.CommandHandlers])
    last = List.last(Module.split(resource))
    name = last <> "Handler"
    Module.concat(ns, name)
  end

  defp command_module(resource, %{name: name} = command) do
    custom_ns = Module.get_attribute(resource, :command_namespace)

    base_parts =
      case custom_ns do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          parts ++ ["Commands"]

        _ ->
          Module.split(custom_ns)
      end

    name_atom = command[:command_name] || Macro.camelize(to_string(name))
    Module.concat(base_parts ++ [name_atom])
  end
end
