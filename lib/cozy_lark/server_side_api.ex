defmodule CozyLark.ServerSideAPI do
  @moduledoc """
  Provides utilities of calling server-side API.

  ## Basic concepts

  + [calling the API](https://open.feishu.cn/document/ukTMukTMukTM/uITNz4iM1MjLyUzM)
  + [full list of supported API](https://open.feishu.cn/document/ukTMukTMukTM/uYTM5UjL2ETO14iNxkTN/server-api-list)

  ## Usage

  First, setup a HTTP client by following:

  + `CozyLark.ServerSideAPI.Client`
  + `CozyLark.ServerSideAPI.Client.Finch`

  Then, create a dedicated module according to your requirements:

      defmodule Demo.GroupManager do
        alias CozyLark.ServerSideAPI
        alias CozyLark.ServerSideAPI.Config

        def list_groups() do
          config()
          |> ServerSideAPI.build!(%{
            access_token_type: :tenant_access_token,
            method: "GET",
            path: "/im/v1/chats"
          })
          |> ServerSideAPI.request()
        end

        defp config() do
          :demo
          |> Application.fetch_env!(__MODULE__)
          |> Enum.into(%{})
          |> Config.new!()
        end
      end

      # config/runtime.exs
      config :demo, Demo.GroupManager,
        platform: :feishu,
        app_type: :custom_app,
        app_id: System.fetch_env!("FEISHU_APP_ID"),
        app_secret: System.fetch_env!("FEISHU_APP_SECRET")

  """

  alias __MODULE__.Config
  alias __MODULE__.Spec
  alias __MODULE__.Request
  alias __MODULE__.AccessToken
  alias __MODULE__.Client

  @doc """
  Bulids a struct that represents a server-side API request.

  See `CozyLark.ServerSideAPI.Spec.build!/1` and `CozyLark.ServerSideAPI.Request.build!/2` for more
  information.
  """
  @spec build!(Config.t(), Spec.config()) :: any()
  def build!(%Config{} = config, spec_config) do
    spec = Spec.build!(spec_config)
    Request.build!(config, spec)
  end

  @doc """
  Sends the server-side API request.

  Before sending the request, this function will try to set access token on the request automatically.
  """
  def request(%Request{} = req) do
    req
    |> AccessToken.maybe_set_access_token()
    |> Client.request()
  end
end
