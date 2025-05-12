  defmodule MyApp.Domain do

    use Ash.Domain

    resources do
      resource MyApp.User
    end

    commanded do
      application do
        otp_app :integration_test
        name MyApp
        event_store Commanded.EventStore.Adapters.InMemory
      end
    end
  end
