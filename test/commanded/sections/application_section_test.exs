defmodule AshCommanded.Commanded.Sections.ApplicationSectionTest do
  use ExUnit.Case, async: true
  
  alias AshCommanded.Commanded.Sections.ApplicationSection
  
  describe "schema/0" do
    test "returns the application schema configuration" do
      schema = ApplicationSection.schema()
      
      assert is_list(schema)
      
      # Check required fields
      assert Keyword.has_key?(schema, :otp_app)
      assert Keyword.get(schema[:otp_app], :required) == true
      assert Keyword.get(schema[:otp_app], :type) == :atom
      
      assert Keyword.has_key?(schema, :event_store)
      assert Keyword.get(schema[:event_store], :required) == true
      assert Keyword.get(schema[:event_store], :type) == :module
      
      # Check optional fields
      assert Keyword.has_key?(schema, :pubsub)
      assert Keyword.get(schema[:pubsub], :type) == :module
      
      assert Keyword.has_key?(schema, :registry)
      assert Keyword.get(schema[:registry], :type) == :module
      
      assert Keyword.has_key?(schema, :snapshotting)
      assert Keyword.get(schema[:snapshotting], :type) == :keyword_list
      
      assert Keyword.has_key?(schema, :serializer)
      assert Keyword.get(schema[:serializer], :type) == :module
      
      assert Keyword.has_key?(schema, :router_module_name)
      assert Keyword.get(schema[:router_module_name], :type) == :atom
      
      assert Keyword.has_key?(schema, :application_module_name)
      assert Keyword.get(schema[:application_module_name], :type) == :atom
      
      assert Keyword.has_key?(schema, :include_supervisor?)
      assert Keyword.get(schema[:include_supervisor?], :type) == :boolean
      assert Keyword.get(schema[:include_supervisor?], :default) == true
    end
  end
  
  describe "entities/0" do
    test "returns an empty list" do
      entities = ApplicationSection.entities()
      
      assert is_list(entities)
      assert entities == []
    end
  end
end