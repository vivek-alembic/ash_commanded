defmodule AshCommanded.Commanded.Transformers.IntegrationTest do
  use ExUnit.Case, async: false
  
  alias AshCommanded.Commanded.Transformers.GenerateCommandModules
  
  describe "command module generation" do
    defmodule TestResource do
      use Ash.Resource,
        extensions: [AshCommanded.Commanded.Dsl],
        domain: nil
      
      attributes do
        uuid_primary_key :id
        attribute :email, :string
        attribute :name, :string
      end
      
      commanded do
        commands do
          command :register_user do
            fields [:id, :email, :name]
            identity_field :id
          end
        end
      end
    end
    
    test "transformer is properly configured" do
      # Verify the transformer function exists
      assert function_exported?(GenerateCommandModules, :transform, 1)
    end
  end
end