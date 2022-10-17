defmodule CozyLark.OpenAPI.AccessToken do
  @moduledoc """
  Provides utilities of getting access token.

  Read more at
  [Related API - Access Token](https://open.feishu.cn/document/ukTMukTMukTM/ukDNz4SO0MjL5QzM/auth-v3/auth/tenant_access_token_internal).
  """

  alias CozyLark.HTTPClient
  alias CozyLark.OpenAPI.Domain

  @supported_api %{
    {:custom_app, :tenant_access_token} => %{
      method: :post,
      path: "/auth/v3/tenant_access_token/internal",
      body_required_keys: [:app_id, :app_secret]
    },
    {:custom_app, :app_access_token} => %{
      method: :post,
      path: "/auth/v3/app_access_token/internal",
      body_required_keys: [:app_id, :app_secret]
    }
  }

  # TODO: add cache
  def get_access_token(domain, app_type, access_token_type, body)
      when app_type in [:custom_app] and
             access_token_type in [:tenant_access_token, :app_access_token] and
             is_map(body) do
    %{method: method, path: path, body_required_keys: body_required_keys} =
      Map.fetch!(@supported_api, {app_type, access_token_type})

    url =
      domain
      |> Domain.fetch_base_url!()
      |> Path.join(path)

    with :ok <- check_request_body(body, body_required_keys),
         {:ok, response} <- HTTPClient.request_json(method, url, %{}, %{}, body),
         %{"code" => code} <- response do
      if code == 0 do
        access_token = Map.fetch!(response, to_string(access_token_type))
        {:ok, access_token}
      else
        {:error, {:server_error_code, code}}
      end
    end
  end

  def check_request_body(body, required_keys) do
    if Enum.all?(required_keys, &Map.has_key?(body, &1)) do
      :ok
    else
      {:error, {:access_token, :bad_body}}
    end
  end
end
