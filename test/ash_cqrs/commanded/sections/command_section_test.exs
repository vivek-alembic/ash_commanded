defmodule AshCommanded.Commanded.Sections.CommandsSectionTest do
  use ExUnit.Case, async: true

  alias AshCommanded.Commanded.Sections.CommandsSection

  describe "build/0" do
    test "returns a Spark.Dsl.Section with correct name and schema" do
      section = CommandsSection.build()

      assert %Spark.Dsl.Section{name: :commands} = section

      assert [
               {:name, [type: :atom, required: true]},
               {:fields, [type: {:list, :atom}, required: true]},
               {:identity_field, [type: :atom, required: true]}
             ] = section.schema
    end

    test "includes a single :command entity with correct schema" do
      section = CommandsSection.build()
      [entity] = section.entities

      assert %Spark.Dsl.Entity{name: :command} = entity
      assert entity.target == AshCommanded.Commanded.Command
      assert entity.args == [:name]

      assert [
               {:name, [type: :atom, required: true]},
               {:fields, [type: {:list, :atom}, required: true]},
               {:identity_field, [type: :atom, required: true]}
             ] = entity.schema
    end
  end
end
