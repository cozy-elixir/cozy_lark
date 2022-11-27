defmodule CozyLark.ServerSideAPI do
  @moduledoc """
  Provides utilities of calling server-side API.

  See [Getting Started - Calling the API](https://open.feishu.cn/document/ukTMukTMukTM/uITNz4iM1MjLyUzM)
  for a quick start.

  See [Getting Started - API list](https://open.feishu.cn/document/ukTMukTMukTM/uYTM5UjL2ETO14iNxkTN/server-api-list)
  for the full list of supported API.
  """

  alias __MODULE__.Config
  alias __MODULE__.Spec
  alias __MODULE__.Request
  alias __MODULE__.AccessToken
  alias __MODULE__.Client

  @doc """
  Bulids a struct `%CozyLark.ServerSideAPI.Request{}`.

  See `CozyLark.ServerSideAPI.build!/2` for more information.
  """
  @spec build!(Config.t(), Spec.config()) :: any()
  def build!(%Config{} = config, spec_config) do
    spec = Spec.build!(spec_config)
    Request.build!(config, spec)
  end

  def request(req) do
    req
    |> AccessToken.maybe_set_access_token()
    |> Client.request()
  end
end
