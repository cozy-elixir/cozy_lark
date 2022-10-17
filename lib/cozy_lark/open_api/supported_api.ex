defmodule CozyLark.OpenAPI.SupportedAPI do
  @moduledoc """
  Provides basic info of supported API.

  The full list of supported API can be found at
  [Getting Started - API list](https://open.feishu.cn/document/ukTMukTMukTM/uYTM5UjL2ETO14iNxkTN/server-api-list).

  # Notice

  I only add what I need for now.

  If you need full support of the API, contribute it.
  """

  @supported_api %{
    "/im/v1/messages" => %{
      method: :post,
      auth_type: :tenant_access_token,
      supported_app_types: [:custom_app, :store_app]
    },
    "/im/v1/messages/:message_id/reply" => %{
      method: :post,
      auth_type: :tenant_access_token,
      supported_app_types: [:custom_app, :store_app]
    },
    "/im/v1/messages/:message_id" => %{
      method: :get,
      auth_type: :tenant_access_token,
      supported_app_types: [:custom_app, :store_app]
    }
  }

  @doc """
  Find related API info by path.
  """
  def find(path) when is_binary(path) do
    default = {:error, :unsupported_api}

    Enum.find_value(@supported_api, default, fn {route, info} ->
      if match_route?(path, route) do
        {:ok, info}
      end
    end)
  end

  # https://stackoverflow.com/a/53680520/16821348
  defp match_route?(path, route) do
    pattern = String.replace(route, ~r/:(\w+)/, ~S"(?<\g{1}>[\w-]+)")
    regex = ~r/^#{pattern}$/
    Regex.match?(regex, path)
  end
end
