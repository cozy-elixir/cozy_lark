defmodule CozyLark.ServerSideAPI.AccessToken do
  @moduledoc """
  Provides utilities of getting access token.

  Read more at
  [Related API - Access Token](https://open.feishu.cn/document/ukTMukTMukTM/ukDNz4SO0MjL5QzM/auth-v3/auth/tenant_access_token_internal).

  # Overview

  There're 3 types of access tokens:

  + `app_access_token`
  + `tenant_access_token`
  + `user_access_token` (not supported for now)

  """

  require Logger
  alias CozyLark.ServerSideAPI.Config
  alias CozyLark.ServerSideAPI.Spec
  alias CozyLark.ServerSideAPI.Request
  alias CozyLark.ServerSideAPI.Client

  def maybe_set_access_token(%Request{} = req) do
    %{config: config} = req.private
    %{access_token_type: type} = req.meta

    case get_access_token(config, type) do
      {:ok, {access_token, _expire}} ->
        Request.set_header(req, "authorization", "Bearer #{access_token}")

      _ ->
        Logger.error("failed to get access token", app: "cozy_lark")
        req
    end
  end

  def get_access_token(%Config{} = config, type) do
    {spec, access_token_key, expire_key} =
      get_spec({config.app_type, type}, config.app_id, config.app_secret)

    spec
    |> then(&Request.build!(config, &1))
    |> Client.request()
    |> case do
      {
        :ok,
        200,
        _headers,
        %{"code" => 0, ^access_token_key => access_token, ^expire_key => expire}
      } ->
        {:ok, {access_token, expire}}

      _ ->
        {:error, :failed_to_get_access_token}
    end
  end

  defp get_spec({:custom_app, :tenant_access_token}, app_id, app_secret) do
    spec =
      Spec.build!(%{
        access_token_type: nil,
        method: "POST",
        path: "/auth/v3/tenant_access_token/internal",
        body: %{
          app_id: app_id,
          app_secret: app_secret
        }
      })

    {spec, "tenant_access_token", "expire"}
  end

  defp get_spec({:custom_app, :app_access_token}, app_id, app_secret) do
    spec =
      Spec.build!(%{
        access_token_type: nil,
        method: "POST",
        path: "/auth/v3/app_access_token/internal",
        body: %{
          app_id: app_id,
          app_secret: app_secret
        }
      })

    {spec, "app_access_token", "expire"}
  end

  defp get_spec({:store_app, :tenant_access_token}, app_id, app_secret) do
    spec =
      Spec.build!(%{
        access_token_type: nil,
        method: "POST",
        path: "/auth/v3/tenant_access_token",
        body: %{
          app_id: app_id,
          app_secret: app_secret
        }
      })

    {spec, "tenant_access_token", "expire"}
  end

  defp get_spec({:store_app, :app_access_token}, app_id, app_secret) do
    spec =
      Spec.build!(%{
        access_token_type: nil,
        method: "POST",
        path: "/auth/v3/app_access_token",
        body: %{
          app_id: app_id,
          app_secret: app_secret
        }
      })

    {spec, "app_access_token", "expire"}
  end
end
