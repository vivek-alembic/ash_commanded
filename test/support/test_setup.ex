defmodule AshCommanded.TestSetup do
  @moduledoc """
  Handles test setup to ensure all generated modules are available before tests.
  """

  @doc """
  Ensures all modules needed for testing are generated.
  """
  def ensure_all_modules_generated(resource) do
    cmd_mod = Module.concat([AshCommanded, Commanded, Transformers, "GenerateCommandModules"])
    event_mod = Module.concat([AshCommanded, Commanded, Transformers, "GenerateEventModules"])
    proj_mod = Module.concat([AshCommanded, Commanded, Transformers, "GenerateProjectionModules"])
    agg_mod = Module.concat([AshCommanded, Commanded, Transformers, "GenerateAggregateModule"])
    
    # Run the transformers in the right order
    {:ok, resource} = apply(cmd_mod, :transform, [resource])
    {:ok, resource} = apply(event_mod, :transform, [resource])
    {:ok, resource} = apply(proj_mod, :transform, [resource])
    {:ok, resource} = apply(agg_mod, :transform, [resource])
    
    # Return the resource with all modules generated
    resource
  end

  @doc """
  Manually create and load event modules for testing.
  """
  def manual_create_event_modules() do
    # User Registered event
    user_registered_mod = Module.concat(["Events", "UserRegistered"])
    unless Code.ensure_loaded?(user_registered_mod) do
      {:module, ^user_registered_mod, _, _} = 
        Module.create(
          user_registered_mod,
          quote do
            @moduledoc "Manual test event module for user_registered"
            defstruct [:id, :name, :email]
          end,
          Macro.Env.location(__ENV__)
        )
    end
    
    # Email Confirmed event
    email_confirmed_mod = Module.concat(["Events", "EmailConfirmed"])
    unless Code.ensure_loaded?(email_confirmed_mod) do
      {:module, ^email_confirmed_mod, _, _} = 
        Module.create(
          email_confirmed_mod,
          quote do
            @moduledoc "Manual test event module for email_confirmed"
            defstruct [:id]
          end,
          Macro.Env.location(__ENV__)
        )
    end
  end
end