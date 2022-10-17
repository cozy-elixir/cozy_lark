defmodule CozyLark.OpenAPI.SupportedAPITest do
  use ExUnit.Case
  alias CozyLark.OpenAPI.SupportedAPI

  describe "find/1" do
    test "gets info of existing API" do
      assert {
               :ok,
               %{
                 method: :post,
                 auth_type: :tenant_access_token,
                 supported_app_types: [:custom_app, :store_app]
               }
             } = SupportedAPI.find("/im/v1/messages")
    end

    test "returns an error tuple when the given path doesn't match any route" do
      assert {:error, :unsupported_api} = SupportedAPI.find("/arbitrary-api")
    end
  end
end
