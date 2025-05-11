# Define the test resource
defmodule AshCommanded.Commanded.DslTest.TestResource do
  use Ash.Resource,
    domain: nil, # no domain needed for basic testing
    extensions: [
      AshCommanded.Commanded.Dsl
    ]

  # Explicitly import the macro for our test to avoid the issue
  # This should ideally be automatically added by Spark.Dsl.Extension
  import AshCommanded.Commanded.Dsl

  attributes do
    uuid_primary_key :id
    attribute :name, :string
  end

  commanded do
    commands do
      command :create_test do
        fields [:name]
        identity_field :id
      end
    end

    events do
      event :test_created do
        fields [:name]
      end
    end
  end
end

defmodule AshCommanded.Commanded.DslTest do
  use ExUnit.Case

  test "extension DSL functionality works properly" do
    # Test that commands section exists and is processed
    commands = AshCommanded.Commanded.Info.commands(AshCommanded.Commanded.DslTest.TestResource)
    assert length(commands) == 1
    
    # Extract the first (and only) command
    command = Enum.find(commands, &(&1.name == :create_test))
    
    # Test command properties
    assert command != nil
    assert command.fields == [:name]
    assert command.identity_field == :id
    
    # Test that events section exists
    events = AshCommanded.Commanded.Info.events(AshCommanded.Commanded.DslTest.TestResource)
    assert length(events) == 1
    
    # Extract the first (and only) event
    event = Enum.find(events, &(&1.name == :test_created))
    
    # Test event properties
    assert event != nil
    assert event.fields == [:name]
  end
  
  test "DSL is properly registered with Spark" do
    extensions = Spark.Dsl.Extension.get_extensions(AshCommanded.Commanded.Dsl)
    assert Enum.any?(extensions, fn ext -> ext.name == :commanded end)
  end
end