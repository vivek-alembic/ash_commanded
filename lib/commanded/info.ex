defmodule AshCommanded.Commanded.Info do
  @moduledoc """
  Read API for the `:commanded` DSL extension.
  Used by transformers and codegen to access DSL sections in a stable way.
  """

  alias Spark.Dsl.Extension
  alias Ash.Domain.Info, as: DomainInfo
  alias Ash.Resource.Info, as: ResourceInfo

  @dsl_path [:commanded]

  @doc """
  Returns the list of command definitions from the resource or DSL state.

  ## Examples

      iex> Info.commands(%{__spark_dsl__: %{commanded: %{commands: [%{name: :foo}]}}})
      [%{name: :foo}]
  """
  def commands(resource_or_dsl) do
    Extension.get_entities(resource_or_dsl, @dsl_path ++ [:commands])
  end

  @doc """
  Returns the list of event definitions from the resource or DSL state.

  ## Examples

      iex> Info.events(%{__spark_dsl__: %{commanded: %{events: [%{name: :created}]}}})
      [%{name: :created}]
  """
  def events(resource_or_dsl) do
    Extension.get_entities(resource_or_dsl, @dsl_path ++ [:events])
  end

  @doc """
  Returns the list of projection definitions from the resource or DSL state.

  ## Examples

      iex> Info.projections(%{__spark_dsl__: %{commanded: %{projections: [%{event: :created}]}}})
      [%{event: :created}]
  """
  def projections(resource_or_dsl) do
    Extension.get_entities(resource_or_dsl, @dsl_path ++ [:projections])
  end

  @doc """
  Returns a MapSet of all event names defined in the DSL.
  Useful for validating references.

  ## Examples

      iex> Info.event_names(%{__spark_dsl__: %{commanded: %{events: [%{name: :created}]}}})
      MapSet.new([:created])
  """
  def event_names(resource_or_dsl) do
    resource_or_dsl
    |> events()
    |> Enum.map(& &1.name)
    |> MapSet.new()
  end

  @doc """
  Finds a command by name. Returns nil if not found.

  ## Examples

      iex> Info.find_command(%{__spark_dsl__: %{commanded: %{commands: [%{name: :foo}]}}}, :foo)
      %{name: :foo}

      iex> Info.find_command(%{__spark_dsl__: %{commanded: %{commands: [%{name: :bar}]}}}, :foo)
      nil
  """
  def find_command(resource_or_dsl, name) do
    Enum.find(commands(resource_or_dsl), &(&1.name == name))
  end

  @doc """
  Finds an event by name. Returns nil if not found.

  ## Examples

      iex> Info.find_event(%{__spark_dsl__: %{commanded: %{events: [%{name: :created}]}}}, :created)
      %{name: :created}
  """
  def find_event(resource_or_dsl, name) do
    Enum.find(events(resource_or_dsl), &(&1.name == name))
  end

  @doc """
  Finds a projection by its associated event name. Returns nil if not found.

  ## Examples

      iex> Info.find_projection(%{__spark_dsl__: %{commanded: %{projections: [%{event: :created}]}}}, :created)
      %{event: :created}
  """
  def find_projection(resource_or_dsl, event_name) do
    Enum.find(projections(resource_or_dsl), &(&1.event == event_name))
  end
  
  @doc """
  Returns the application configuration from the domain.
  
  ## Examples
  
      iex> Info.application_config(%{__spark_dsl__: %{commanded: %{application: %{otp_app: :my_app}}}})
      %{otp_app: :my_app}
  """
  def application_config(domain) do
    Extension.get_opt(domain, @dsl_path ++ [:application], :config, %{})
  end

  @doc """
  Returns the application module name.
  
  If a :name is specified in the configuration, it's used.
  Otherwise, the domain name with "CommandedApp" suffix is used.
  
  ## Examples
  
      iex> Info.application_name(%{__spark_dsl__: %{commanded: %{application: %{name: MyApp}}}})
      MyApp
  """
  def application_name(domain) do
    app_name = Extension.get_opt(domain, @dsl_path ++ [:application], :name)
    
    if app_name do
      app_name
    else
      parts = Module.split(domain)
      Module.concat(parts ++ ["CommandedApp"])
    end
  end
  
  @doc """
  Checks if the domain has application configuration.
  """
  def has_application_config?(domain) do
    !Enum.empty?(application_config(domain))
  end
  
  @doc """
  Returns a list of all projector modules that should be supervised by the application.
  """
  def projector_modules(domain) do
    resources = DomainInfo.resources(domain)
    
    resources
    |> Enum.filter(fn resource -> 
      Code.ensure_loaded?(resource) && function_exported?(resource, :__ash_commanded_commanded__, 0)
    end)
    |> Enum.flat_map(fn resource ->
      projections = projections(resource)
      
      unless projections == [] do
        [projector_module_for_resource(resource, projections)]
      else
        []
      end
    end)
  end
  
  @doc """
  Returns the projector module name for a resource.
  """
  def projector_module_for_resource(resource, projections \\ nil) do
    projections = projections || projections(resource)
    
    if projections == [] do
      nil
    else
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
  end
  
  @doc """
  Returns a list of all command modules for a resource.
  """
  def command_modules(resource) do
    resource
    |> commands()
    |> Enum.map(fn command -> command_module_for_command(resource, command) end)
  end
  
  @doc """
  Returns the command module for a specific command.
  """
  def command_module_for_command(resource, command) do
    command_name = command[:command_name] || Macro.camelize(to_string(command.name))
    
    custom_ns = Module.get_attribute(resource, :command_namespace)
    
    base_parts =
      case custom_ns do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          parts ++ ["Commands"]

        _ ->
          Module.split(custom_ns)
      end

    Module.concat(base_parts ++ [command_name])
  end
  
  @doc """
  Returns a list of all event modules for a resource.
  """
  def event_modules(resource) do
    resource
    |> events()
    |> Enum.map(fn event -> event_module_for_event(resource, event) end)
  end
  
  @doc """
  Returns the event module for a specific event.
  """
  def event_module_for_event(resource, event) do
    event_name = event[:event_name] || Macro.camelize(to_string(event.name))
    
    custom_ns = Module.get_attribute(resource, :event_namespace)
    
    base_parts =
      case custom_ns do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          parts ++ ["Events"]

        _ ->
          Module.split(custom_ns)
      end

    Module.concat(base_parts ++ [event_name])
  end
  
  @doc """
  Returns a list of all projection modules for a resource.
  """
  def projection_modules(resource) do
    resource
    |> projections()
    |> Enum.map(fn projection -> projection_module_for_projection(resource, projection) end)
  end
  
  @doc """
  Returns the projection module for a specific projection.
  """
  def projection_module_for_projection(resource, projection) do
    event_name = Macro.camelize(to_string(projection.event))
    
    ns =
      case Module.get_attribute(resource, :projection_namespace) do
        nil ->
          parts = Module.split(resource) |> Enum.drop(-1)
          Module.concat(parts ++ ["Projections"])

        namespace ->
          namespace
      end

    Module.concat(ns, event_name)
  end
  
  @doc """
  Returns the aggregate module for a resource.
  """
  def aggregate_module_for_resource(resource) do
    parts = Module.split(resource)
    ns = Enum.drop(parts, -1)
    name = List.last(parts) <> "Aggregate"
    Module.concat(ns ++ [name])
  end
  
  @doc """
  Returns a list of all aggregate modules in a domain.
  """
  def aggregate_modules(domain) do
    resources = DomainInfo.resources(domain)
    
    resources
    |> Enum.filter(fn resource -> 
      Code.ensure_loaded?(resource) && function_exported?(resource, :__ash_commanded_commanded__, 0)
    end)
    |> Enum.map(&aggregate_module_for_resource/1)
  end
  
  @doc """
  Returns the router module for a domain.
  """
  def domain_router_module(domain) do
    domain_parts = Module.split(domain)
    Module.concat(domain_parts ++ ["Router"])
  end
  
  @doc """
  Returns the command handler module for a resource.
  """
  def command_handler_module_for_resource(resource) do
    ns = Module.concat([AshCommanded.Commanded.CommandHandlers])
    last = List.last(Module.split(resource))
    name = last <> "Handler"
    Module.concat(ns, name)
  end
  
  @doc """
  Returns a list of all command handler modules in a domain.
  """
  def command_handler_modules(domain) do
    resources = DomainInfo.resources(domain)
    
    resources
    |> Enum.filter(fn resource -> 
      Code.ensure_loaded?(resource) && 
      function_exported?(resource, :__ash_commanded_commanded__, 0) &&
      !Enum.empty?(commands(resource))
    end)
    |> Enum.map(&command_handler_module_for_resource/1)
  end
  
  @doc """
  Returns the main router module.
  """
  def main_router_module do
    Module.concat(["AshCommanded", "Router"])
  end
  
  @doc """
  Returns a map of all generated modules for introspection.
  """
  def all_modules(domain) do
    resources = DomainInfo.resources(domain)
    
    commanded_resources = resources
    |> Enum.filter(fn resource -> 
      Code.ensure_loaded?(resource) && function_exported?(resource, :__ash_commanded_commanded__, 0)
    end)
    
    resource_modules = commanded_resources
    |> Enum.flat_map(fn resource ->
      %{
        commands: command_modules(resource),
        events: event_modules(resource),
        projections: projection_modules(resource),
        projector: projector_module_for_resource(resource),
        aggregate: aggregate_module_for_resource(resource),
        command_handler: command_handler_module_for_resource(resource)
      }
    end)
    
    domain_modules = %{
      domain_router: domain_router_module(domain),
      main_router: main_router_module(),
      application: has_application_config?(domain) && application_name(domain)
    }
    
    %{
      resources: resource_modules,
      domain: domain_modules
    }
  end
end
