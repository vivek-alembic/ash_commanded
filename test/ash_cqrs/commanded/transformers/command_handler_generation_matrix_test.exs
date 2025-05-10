defmodule AshCommanded.Commanded.Transformers.CommandHandlerGenerationMatrixTest do
  use ExUnit.Case, async: true

  defmodule CommandGenerationMatrixResource do
    use Ash.Resource,
      extensions: [AshCommanded.Commanded.Dsl]

    @command_namespace AshCommanded.Commanded.GeneratedCommands
    @projector_namespace AshCommanded.Commanded.GeneratedCommandHandlers

    attributes do
      uuid_primary_key :id
      attribute :email, :string
    end

    actions do
      create :create
      update :update_email
    end

    commanded do
      commands do
        command :case1 do
          # ✅ Generate Command + ✅ Generate Handler
          fields([:id, :email])
          action :create
        end

        command :case2 do
          # ✅ Generate Command + ❌ Generate Handler
          fields([:id, :email])
          action :create
          autogenerate_handler?(false)
        end

        command :case3 do
          # ❌ Generate Command + ✅ Generate Handler
          fields([:id, :email])
          action :update_email
          autogenerate?(false)
        end

        command :case4 do
          # ❌ Generate Command + ❌ Generate Handler
          fields([:id, :email])
          action :update_email
          autogenerate?(false)
          autogenerate_handler?(false)
        end
      end
    end
  end

  alias AshCommanded.Commanded.GeneratedCommands.Case1
  alias AshCommanded.Commanded.CommandHandlers.CommandGenerationMatrixResourceHandler

  test "case1: command and handler are generated" do
    assert Code.ensure_loaded?(Case1)
    assert function_exported?(CommandGenerationMatrixResourceHandler, :handle, 2)
  end

  test "case2: command is generated, handler is not" do
    assert Code.ensure_loaded?(AshCommanded.Commanded.GeneratedCommands.Case2)
    refute function_exported?(CommandGenerationMatrixResourceHandler, :handle, 2)
  end

  test "case3: handler is generated, command is not (assumes module defined manually or already exists)" do
    assert function_exported?(CommandGenerationMatrixResourceHandler, :handle, 2)
  end

  test "case4: neither command nor handler is generated" do
    refute Code.ensure_loaded?(AshCommanded.Commanded.GeneratedCommands.Case4)
    refute function_exported?(CommandGenerationMatrixResourceHandler, :handle, 2)
  end
end
