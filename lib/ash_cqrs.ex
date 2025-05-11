defmodule AshCommanded do
  @moduledoc """
  Documentation for `AshCommanded`.

  This library provides Command Query Responsibility Segregation (CQRS)
  and Event Sourcing (ES) patterns for the Ash Framework using Commanded.
  """

  @doc """
  Used to define an AshCommanded resource with CQRS and Event Sourcing capabilities.
  """
  defmacro __using__(opts) do
    quoted_opts = Macro.escape(opts)
    
    quote do
      use Ash.Resource, 
        extensions: [AshCommanded.Commanded.Dsl | Keyword.get(unquote(quoted_opts), :extensions, [])]
      
      import AshCommanded.Commanded.Dsl, only: [commanded: 1]
    end
  end
  
  # Since we're including the extension in the resource directly,
  # we don't need a separate registration method.
  # Ash will automatically pick up the extension when it's included in the resource.
end
