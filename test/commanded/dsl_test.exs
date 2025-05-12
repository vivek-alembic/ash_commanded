defmodule AshCommanded.Commanded.DslTest do
  use ExUnit.Case

  alias MyApp.User

  test "extension DSL functionality works properly" do
    # Test that commands section exists and is processed
    commands = AshCommanded.Commanded.Info.commands(User)
    assert length(commands) == 2

    # Extract the register_user command
    register_command = Enum.find(commands, &(&1.name == :register_user))
    confirm_command = Enum.find(commands, &(&1.name == :confirm_email))

    # Test command properties
    assert register_command != nil
    assert register_command.fields == [:id, :name, :email]
    assert register_command.identity_field == :id

    assert confirm_command != nil
    assert confirm_command.fields == [:id]
    assert confirm_command.identity_field == :id

    # Test that events section exists
    events = AshCommanded.Commanded.Info.events(User)
    assert length(events) == 2

    # Extract the events
    registered_event = Enum.find(events, &(&1.name == :user_registered))
    confirmed_event = Enum.find(events, &(&1.name == :email_confirmed))

    # Test event properties
    assert registered_event != nil
    assert registered_event.fields == [:id, :name, :email]

    assert confirmed_event != nil
    assert confirmed_event.fields == [:id]
  end

  test "DSL is properly registered with Spark" do
    extensions = Spark.Dsl.Extension.get_extensions(AshCommanded.Commanded.Dsl)
    assert Enum.any?(extensions, fn ext -> ext.name == :commanded end)
  end
end