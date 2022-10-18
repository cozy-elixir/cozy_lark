defmodule CozyLark.ServerSideAPI.Config do
  @enforce_keys [:app_id, :app_secret, :app_type, :domain]
  defstruct @enforce_keys

  def validate_config!(config) do
    config
    |> validate_required_config!()
    |> validate_app_type!()
    |> validate_domain!()
    |> then(&struct(__MODULE__, &1))
  end

  defp validate_required_config!(config) do
    if match?(
         %{app_id: app_id, app_secret: app_secret}
         when is_binary(app_id) and is_binary(app_secret),
         config
       ) do
      config
    else
      raise ArgumentError, "config :app_id and :app_secret are required"
    end
  end

  defp validate_app_type!(config) do
    config_key = :app_type
    available_app_types = [:custom_app, :store_app]
    current_app_type = Map.get(config, config_key)

    if current_app_type in available_app_types do
      config
    else
      raise ArgumentError, "config :app_type must be one of #{inspect(available_app_types)}"
    end
  end

  defp validate_domain!(config) do
    config_key = :domain
    available_domains = [:lark, :feishu]
    current_domain = Map.get(config, config_key)

    if current_domain in available_domains do
      config
    else
      raise ArgumentError, "config :domain must be one of #{inspect(available_domains)}"
    end
  end
end
