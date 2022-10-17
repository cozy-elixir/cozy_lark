defmodule CozyLark.EventSubscription.Config do
  @enforce_keys [:verification_token]
  defstruct [
    :verification_token,
    :encrypt_key
  ]

  def validate_config!(config) when is_map(config) do
    config
    |> Map.take([:verification_token, :encrypt_key])
    |> then(&struct(__MODULE__, &1))
  end
end
