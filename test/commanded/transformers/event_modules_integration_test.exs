defmodule AshCommanded.Commanded.Transformers.EventModulesIntegrationTest do
  use ExUnit.Case, async: false
  
  alias AshCommanded.Commanded.Transformers.GenerateEventModules
  
  describe "event module generation" do
    test "transformer is properly configured" do
      # Verify the transformer function exists
      assert function_exported?(GenerateEventModules, :transform, 1)
    end
  end
end