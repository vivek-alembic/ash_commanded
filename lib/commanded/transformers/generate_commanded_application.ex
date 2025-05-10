defmodule AshCommanded.Commanded.Transformers.GenerateCommandedApplication do
  @moduledoc """
  Generates a Commanded.Application module for each domain with Commanded DSL.

  The application module:
  - Configures a Commanded application with proper settings
  - Includes a supervisor for all projectors
  - Registers the main router
  - Provides child_spec and start_link functions

  This allows the application to be easily supervised in the main application.
  """

  @behaviour Spark.Dsl.Transformer

  alias AshCommanded.Commanded.Info

  @impl true
  def transform(domain) do
    # Only process domains, not resources
    if is_domain?(domain) && Info.has_application_config?(domain) do
      create_application_module(domain)
    end

    {:ok, domain}
  end

  defp is_domain?(module) do
    Code.ensure_loaded?(module) && function_exported?(module, :__ash_domain__, 0)
  end

  @impl true
  def after?(_), do: true # Run after all other transformers

  @impl true
  def before?(_), do: false

  @impl true
  def after_compile?, do: true # Run after compilation to ensure all modules are loaded

  defp create_application_module(domain) do
    app_module = Info.application_name(domain)
    config = Info.application_config(domain)
    include_supervisor? = Map.get(config, :include_supervisor?, true)
    
    router_module = Module.concat([domain, "Router"])
    projector_modules = Info.projector_modules(domain)
    otp_app = Map.get(config, :otp_app, :ash_commanded)
    event_store = Map.get(config, :event_store)
    pubsub = Map.get(config, :pubsub)
    registry = Map.get(config, :registry, Commanded.Registration.SwarmRegistry)
    snapshotting = Map.get(config, :snapshotting, false)
    snapshot_every = Map.get(config, :snapshot_every)
    snapshot_version = Map.get(config, :snapshot_version)
    
    # Generate the application module
    unless Code.ensure_loaded?(app_module) do
      module_ast = generate_application_module_ast(
        app_module,
        domain,
        router_module,
        projector_modules,
        otp_app,
        event_store,
        pubsub,
        registry,
        snapshotting,
        snapshot_every,
        snapshot_version,
        include_supervisor?
      )
      
      {:module, ^app_module, _, _} = 
        Module.create(app_module, module_ast, Macro.Env.location(__ENV__))
    end
  end
  
  defp generate_application_module_ast(
    app_module, 
    domain, 
    router_module, 
    projector_modules, 
    otp_app, 
    event_store, 
    pubsub, 
    registry, 
    snapshotting, 
    snapshot_every, 
    snapshot_version,
    include_supervisor?
  ) do
    # Generate config options
    config_options = []
    
    config_options = 
      if event_store do
        config_options ++ [event_store: event_store]
      else
        config_options
      end
      
    config_options = 
      if pubsub do
        config_options ++ [pubsub: pubsub]
      else
        config_options
      end
    
    config_options = 
      if registry do
        config_options ++ [registry: registry]
      else
        config_options
      end
      
    config_options = 
      if snapshotting do
        snapshot_config = [snapshotting: true]
        
        snapshot_config = 
          if snapshot_every do
            snapshot_config ++ [snapshot_every: snapshot_every]
          else
            snapshot_config
          end
          
        snapshot_config = 
          if snapshot_version do
            snapshot_config ++ [snapshot_version: snapshot_version]
          else
            snapshot_config
          end
        
        config_options ++ snapshot_config
      else
        config_options
      end
    
    # Generate supervisor children AST if needed
    supervisor_ast = 
      if include_supervisor? && !Enum.empty?(projector_modules) do
        projector_children_ast = 
          for projector <- projector_modules do
            quote do
              unquote(projector)
            end
          end
        
        quote do
          @doc """
          Returns a supervisor specification for the application and all projectors.
          """
          def child_spec(arg) do
            %{
              id: __MODULE__,
              start: {__MODULE__, :start_link, [arg]},
              type: :supervisor,
              restart: :permanent,
              shutdown: 5000
            }
          end
          
          @doc """
          Starts the application and a supervisor for all projectors.
          """
          def start_link(opts \\ []) do
            import Supervisor.Spec, warn: false
            
            children = [
              unquote_splicing(projector_children_ast)
            ]
            
            opts = Keyword.merge([strategy: :one_for_one, name: __MODULE__.Supervisor], opts)
            Supervisor.start_link(children, opts)
          end
        end
      else
        quote do end
      end
      
    # Generate the module
    
    # Build the options for Commanded.Application as a keyword list
    commanded_options = [otp_app: otp_app] ++ config_options
    
    quote do
      defmodule unquote(app_module) do
        @moduledoc """
        Commanded application for #{inspect(unquote(domain))}.
        
        This module was automatically generated by AshCommanded.
        """
        
        use Commanded.Application, unquote(commanded_options)
          
        router(unquote(router_module))
        
        unquote(supervisor_ast)
      end
    end
  end
end
