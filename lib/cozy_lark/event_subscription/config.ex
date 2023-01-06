defmodule CozyLark.EventSubscription.Config do
  @enforce_keys [:verification_token]
  defstruct [
    :verification_token,
    :encrypt_key
  ]

  @type config() :: %{
          verification_token: String.t() | nil,
          encrypt_key: String.t() | nil
        }

  @type t :: %__MODULE__{
          verification_token: String.t() | nil,
          encrypt_key: String.t() | nil
        }

  @spec new!(config()) :: t()
  def new!(config) do
    config
    |> as_struct!()
  end

  defp as_struct!(config) do
    default_struct = __MODULE__.__struct__()
    valid_keys = Map.keys(default_struct)
    config = Map.take(config, valid_keys)
    Map.merge(default_struct, config)
  end
end
