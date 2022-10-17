defmodule CozyLark.OpenAPI.API do
  @moduledoc """
  Provides utilities of calling API.

  The full list of supported API can be found at
  [Getting Started - API list](https://open.feishu.cn/document/ukTMukTMukTM/uYTM5UjL2ETO14iNxkTN/server-api-list).

  # Notice

  I only add what I need for now.

  If you need full support of the API, contribute it.
  """

  alias CozyLark.HTTPClient
  alias CozyLark.OpenAPI.Config
  alias CozyLark.OpenAPI.Domain
  alias CozyLark.OpenAPI.AccessToken

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
  Call an API.
  """
  def call(
        %Config{
          app_type: app_type,
          domain: domain
        } = config,
        path,
        query_params,
        body_params
      ) do
    with {:ok,
          %{
            method: method,
            auth_type: auth_type,
            supported_app_types: supported_app_types
          }} <- get_api_info(path),
         :ok <- check_app_type(app_type, supported_app_types) do
      url = Domain.build_url!(domain, path)

      with {:ok, access_token} <- AccessToken.get_access_token(config, auth_type),
           {:ok, response} <-
             HTTPClient.request_json(
               method,
               url,
               %{"Authorization" => "Bearer #{access_token}"},
               query_params,
               body_params
             ),
           %{"code" => code} <- response do
        if code == 0 do
          data = Map.fetch!(response, "data")
          {:ok, data}
        else
          {:error, {:server_error_code, code}}
        end
      end
    end
  end

  defp get_api_info(path) when is_binary(path) do
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

  defp check_app_type(app_type, supported_app_types) do
    if app_type in supported_app_types do
      :ok
    else
      {:error, :unsupported_app_type}
    end
  end
end
