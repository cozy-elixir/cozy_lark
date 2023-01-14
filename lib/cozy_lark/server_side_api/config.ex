defmodule CozyLark.ServerSideAPI.Config do
  @moduledoc """
  Provides config for server-side API.
  """

  @enforce_keys [:platform, :app_type, :app_id, :app_secret]
  defstruct @enforce_keys

  @type config() :: %{
          platform: :lark | :feishu,
          app_type: :custom_app | :store_app,
          app_id: String.t(),
          app_secret: String.t()
        }

  @type t :: %__MODULE__{
          platform: :lark | :feishu,
          app_type: :custom_app | :store_app,
          app_id: String.t(),
          app_secret: String.t()
        }

  @doc """
  Creates a config from a given map.
  """
  @spec new!(config()) :: t()
  def new!(config) do
    config
    |> validate_required_keys!()
    |> validate_platform!()
    |> validate_app_type!()
    |> as_struct!()
  end

  defp validate_required_keys!(config) do
    if match?(
         %{platform: platform, app_type: app_type, app_id: app_id, app_secret: app_secret}
         when is_atom(platform) and
                is_atom(app_type) and
                is_binary(app_id) and
                is_binary(app_secret),
         config
       ) do
      config
    else
      raise ArgumentError, "key :platform, :app_type, :app_id, :app_secret are required"
    end
  end

  defp validate_platform!(config) do
    available_platforms = [:lark, :feishu]
    current_platform = config.platform

    if current_platform in available_platforms do
      config
    else
      raise ArgumentError,
            "unknown value of key :platform - #{inspect(current_platform)}"
    end
  end

  defp validate_app_type!(config) do
    available_app_types = [:custom_app, :store_app]
    current_app_type = config.app_type

    if current_app_type in available_app_types do
      config
    else
      raise ArgumentError,
            "unknown value of key :app_type - #{inspect(current_app_type)}"
    end
  end

  defp as_struct!(config) do
    default_struct = __MODULE__.__struct__()
    valid_keys = Map.keys(default_struct)
    config = Map.take(config, valid_keys)
    Map.merge(default_struct, config)
  end
end
