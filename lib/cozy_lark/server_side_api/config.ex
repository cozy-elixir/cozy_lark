defmodule CozyLark.ServerSideAPI.Config do
  @enforce_keys [:app_id, :app_secret, :app_type, :domain]
  defstruct @enforce_keys

  @type config() :: %{
          app_id: String.t(),
          app_secret: String.t(),
          app_type: :custom_app | :store_app,
          domain: :lark | :feishu
        }

  @type t :: %__MODULE__{
          app_id: String.t(),
          app_secret: String.t(),
          app_type: :custom_app | :store_app,
          domain: :lark | :feishu
        }

  @spec new!(config()) :: t()
  def new!(config) do
    config
    |> validate_required_keys!()
    |> validate_app_type!()
    |> validate_domain!()
    |> as_struct!()
  end

  defp validate_required_keys!(config) do
    if match?(
         %{app_id: app_id, app_secret: app_secret}
         when is_binary(app_id) and is_binary(app_secret),
         config
       ) do
      config
    else
      raise ArgumentError, "key :app_id, :app_secret, :app_type, :domain are required"
    end
  end

  defp validate_app_type!(config) do
    config_key = :app_type
    available_app_types = [:custom_app, :store_app]
    current_app_type = Map.get(config, config_key)

    if current_app_type in available_app_types do
      config
    else
      raise ArgumentError,
            "the value of key :app_type must be one of #{inspect(available_app_types)}"
    end
  end

  defp validate_domain!(config) do
    config_key = :domain
    available_domains = [:lark, :feishu]
    current_domain = Map.get(config, config_key)

    if current_domain in available_domains do
      config
    else
      raise ArgumentError, "the value of key :domain must be one of #{inspect(available_domains)}"
    end
  end

  defp as_struct!(config) do
    default_struct = __MODULE__.__struct__()
    valid_keys = Map.keys(default_struct)
    config = Map.take(config, valid_keys)
    Map.merge(default_struct, config)
  end
end
