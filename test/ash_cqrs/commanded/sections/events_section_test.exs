defmodule AshCommanded.Commanded.Sections.EventsSectionTest do
  use ExUnit.Case, async: true

  alias AshCommanded.Commanded.Sections.EventsSection

  describe "build/0" do
    test "returns a Spark.Dsl.Section with correct name" do
      section = EventsSection.build()

      assert %Spark.Dsl.Section{name: :events} = section
      assert section.schema == []
    end

    test "includes a single :event entity with correct schema" do
      section = EventsSection.build()
      [entity] = section.entities

      assert %Spark.Dsl.Entity{name: :event} = entity
      assert entity.target == AshCommanded.Commanded.Event
      assert entity.args == [:name]

      assert [
               {:name, [type: :atom, required: true]},
               {:fields, [type: {:list, :atom}, required: true]}
             ] = entity.schema
    end
  end
end
