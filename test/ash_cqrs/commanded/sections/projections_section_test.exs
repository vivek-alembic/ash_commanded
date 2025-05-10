defmodule AshCommanded.Commanded.Sections.ProjectionsSectionTest do
  use ExUnit.Case, async: true

  alias AshCommanded.Commanded.Sections.ProjectionsSection

  describe "build/0" do
    test "returns a Spark.Dsl.Section with correct name" do
      section = ProjectionsSection.build()

      assert %Spark.Dsl.Section{name: :projections} = section
      assert section.schema == []
    end

    test "includes a single :projection entity with correct schema" do
      section = ProjectionsSection.build()
      [entity] = section.entities

      assert %Spark.Dsl.Entity{name: :projection} = entity
      assert entity.target == AshCommanded.Commanded.Projection
      assert entity.args == [:event]

      assert [
               {:event, [type: :atom, required: true]},
               {:changes, [type: {:map, :atom}, required: true]}
             ] = entity.schema
    end
  end
end
