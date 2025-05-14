defmodule AshCommanded.Commanded.ApplicationDslTest do
  use ExUnit.Case, async: true
  
  defmodule FakeEventStore do
    # A stub module for testing
  end
  
  defmodule FakePubSub do
    # A stub module for testing
  end
  
  defmodule FakeRegistry do
    # A stub module for testing
  end
  
  defmodule FakeSerializer do
    # A stub module for testing
  end
  
  defmodule DomainWithApplication do
    use Ash.Domain,
      extensions: [AshCommanded.Commanded.Domain.Dsl],
      validate_config_inclusion?: false
    
    commanded do
      application do
        otp_app :my_app
        event_store FakeEventStore
        pubsub FakePubSub
        registry FakeRegistry
        snapshotting [
          snapshot_every: 5,
          snapshot_version: 1
        ]
        serializer FakeSerializer
        router_module_name :MyRouter
        application_module_name :MyCommandedApp
        include_supervisor? true
      end
    end
  end
      
  describe "application DSL" do
    test "domain can define application configuration" do
      # Just checking that the module compiles successfully
      assert Code.ensure_loaded?(DomainWithApplication)
      
      # Get each configuration option individually
      otp_app = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :otp_app)
      event_store = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :event_store)
      pubsub = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :pubsub)
      registry = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :registry)
      snapshotting = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :snapshotting)
      serializer = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :serializer)
      router_module_name = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :router_module_name)
      application_module_name = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :application_module_name)
      include_supervisor? = Spark.Dsl.Extension.get_opt(DomainWithApplication, [:commanded, :application], :include_supervisor?)
      
      # Check that the application configuration is correct
      assert otp_app == :my_app
      assert event_store == FakeEventStore
      assert pubsub == FakePubSub
      assert registry == FakeRegistry
      assert is_list(snapshotting)
      assert snapshotting[:snapshot_every] == 5
      assert snapshotting[:snapshot_version] == 1
      assert serializer == FakeSerializer
      assert router_module_name == :MyRouter
      assert application_module_name == :MyCommandedApp
      assert include_supervisor? == true
    end
  end
end