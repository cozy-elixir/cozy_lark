defmodule CozyLark.EventSubscription.Opts do
  @moduledoc """
  Currently, only option `security_verification_method` is supported.

  ## Available options

  + `security_verification_method` - specify the method to verify that the event is sent by
    Lark Open Platform and not a forgery.

  """

  @enforce_keys [:security_verification_method]
  defstruct @enforce_keys

  alias CozyLark.EventSubscription.Config

  @type signature_factors() :: %{
          raw_body: String.t(),
          timestamp: String.t(),
          nonce: String.t(),
          signature: String.t()
        }

  @type opts() :: [
          security_verification_method: :verification_token | {:signature, signature_factors()}
        ]

  @type t :: %__MODULE__{
          security_verification_method: :verification_token | {:signature, signature_factors()}
        }

  @spec validate_opts!(opts(), Config.t()) :: t()
  def validate_opts!(opts, %Config{} = config) when is_list(opts) do
    opts
    |> cast_opts()
    |> validate_security_verification_method!()
    |> validate_required_config!(config)
    |> validate_signature_factors!()
  end

  defp cast_opts(opts) do
    opts
    |> Enum.into(%{})
    |> then(&struct(__MODULE__, &1))
  end

  defp validate_security_verification_method!(%__MODULE__{} = opts) do
    opt_key = :security_verification_method
    current_method = Map.get(opts, opt_key)

    case current_method do
      :verification_token ->
        opts

      {:signature, _factors} ->
        opts

      _ ->
        raise ArgumentError,
              "unknown value of option #{inspect(opt_key)} - #{inspect(current_method)}"
    end
  end

  defp validate_required_config!(
         %__MODULE__{security_verification_method: :verification_token} = opts,
         config
       ) do
    if match?(%{verification_token: token} when is_binary(token), config) do
      opts
    else
      raise ArgumentError,
            "option [security_verification_method: :verification_token] requires config :verfication_token"
    end
  end

  defp validate_required_config!(
         %__MODULE__{security_verification_method: {:signature, _factors}} = opts,
         config
       ) do
    if match?(
         %{verification_token: token, encrypt_key: key} when is_binary(token) and is_binary(key),
         config
       ) do
      opts
    else
      raise ArgumentError,
            "option [security_verification_method: {:signature, _}] requires config :verfication_token and :encrypt_key"
    end
  end

  defp validate_signature_factors!(
         %__MODULE__{security_verification_method: {:signature, factors}} = opts
       ) do
    if match?(
         %{
           raw_body: raw_body,
           timestamp: timestamp,
           nonce: nonce,
           signature: signature
         }
         when is_binary(raw_body) and
                is_binary(timestamp) and
                is_binary(nonce) and
                is_binary(signature),
         factors
       ) do
      opts
    else
      raise ArgumentError,
            Enum.join(
              [
                "option [security_verification_method: {:signature, factors}] requires the factors to be a map with following keys:",
                "+ raw_body",
                "+ timestamp",
                "+ nonce",
                "+ signature"
              ],
              "\n"
            )
    end
  end

  defp validate_signature_factors!(%__MODULE__{} = opts) do
    opts
  end
end
