defmodule CozyLark.OpenAPI do
  @moduledoc """
  Provides utilities of calling open API.

  Read more at
  [Getting Started - Calling the API](https://open.feishu.cn/document/ukTMukTMukTM/uITNz4iM1MjLyUzM).

  # Overview

  ## supported API

  Read more at `CozyLark.OpenAPI.API`.

  # Usage

  ## about `config`

  It's a map with following keys:
  + `app_id`
  + `app_secret`
  + `app_type`
    - `:custom_app`
    - `:store_app` (TODO)
  + `domain`
    - `:lark`
    - `:feishu`

  """

  alias __MODULE__.Config
  alias __MODULE__.API

  def call(config, path, query_params, body_params) do
    config = Config.validate_config!(config)
    API.call(config, path, query_params, body_params)
  end
end
