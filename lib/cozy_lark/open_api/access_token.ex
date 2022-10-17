defmodule CozyLark.OpenAPI.AccessToken do
  @moduledoc """
  Provides utilities of getting access token.

  Read more at
  [Related API - Access Token](https://open.feishu.cn/document/ukTMukTMukTM/ukDNz4SO0MjL5QzM/auth-v3/auth/tenant_access_token_internal).
  """

  alias CozyLark.HTTPClient
  alias CozyLark.OpenAPI.Config
  alias CozyLark.OpenAPI.Domain

  @supported_api %{
    {:custom_app, :tenant_access_token} => %{
      method: :post,
      path: "/auth/v3/tenant_access_token/internal"
    },
    {:custom_app, :app_access_token} => %{
      method: :post,
      path: "/auth/v3/app_access_token/internal"
    }
  }

  # TODO: add cache
  def get_access_token(
        %Config{
          app_id: app_id,
          app_secret: app_secret,
          app_type: :custom_app = app_type,
          domain: domain
        },
        access_token_type
      )
      when access_token_type in [:tenant_access_token, :app_access_token] do
    %{method: method, path: path} = fetch_api_info!(app_type, access_token_type)
    url = Domain.build_url!(domain, path)
    body = %{app_id: app_id, app_secret: app_secret}

    with {:ok, response} <- HTTPClient.request_json(method, url, %{}, %{}, body),
         %{"code" => code} <- response do
      if code == 0 do
        access_token = Map.fetch!(response, to_string(access_token_type))
        {:ok, access_token}
      else
        {:error, {:server_error_code, code}}
      end
    end
  end

  defp fetch_api_info!(app_type, access_token_type) do
    Map.fetch!(@supported_api, {app_type, access_token_type})
  end
end
