defmodule CozyLark.EventSubscription do
  @moduledoc """
  Provides utilities of event subscription:
  + resolving the challenge request when configuring the request URL.
  + transforming V2.0 events into `CozyLark.EventSubscription.Event`.

  Read more at [Subscribe to events](https://open.feishu.cn/document/ukTMukTMukTM/uUTNz4SN1MjL1UzM).

  # Overview

  ## subscription process

  1. setup `verification_token`
  2. setup `encrypt_key`
  3. configure the request URL
  4. add events
  5. apply for scopes
  6. receive and process events

  Utilities provided by this module can be used at step 3 and 6.

  ## supported events

  The full list of events can be found at
  [Getting Started - Event list](https://open.feishu.cn/document/ukTMukTMukTM/uYDNxYjL2QTM24iN0EjN/event-list).

  Only the V2.0 events are supported.

  # Usage

     alias CozyLark.EventSubscription
     EventSubscription.process_event(payload, config, opts)

  ## about `config`

  It's a map with following keys:
  + `verification_token`
  + `encrypt_key`

  ## about `opts`

  It's a keyword list with following keys:
  + `security_verification_method` - specify the method to verify that the event is sent by
    Lark Open Platform and not a forgery. Available values are:
    - `verification_token`
    - `{:signature, factors}` where the `factors` is a map with following keys:
      + `raw_body`
      + `timestamp`
      + `nonce`
      + `signature`

  ## examples

  Verify event by `:verification_token` method, and process event:

     process_event(
       payload,
       %{verification_token: "...", encrypt_key: "..."},
       security_verification_method: :verification_token
     )

  Verify event by `:signature` method, and process event:

     process_event(
       payload,
       %{verification_token: "...", encrypt_key: "..."},
       security_verification_method: {:signature, %{
         raw_body: "...",
         timestamp: "...",
         nonce: "...",
         signature: "..."
       }}
     )

  # More details

  + [Event processing method - Security verification](https://open.feishu.cn/document/ukTMukTMukTM/uYDNxYjL2QTM24iN0EjN/event-subscription-configure-/encrypt-key-encryption-configuration-case?lang=en-US#d41e8916).
  + [Event processing method - Event decryption](https://open.feishu.cn/document/ukTMukTMukTM/uYDNxYjL2QTM24iN0EjN/event-subscription-configure-/encrypt-key-encryption-configuration-case?lang=en-US#58c980bc).

  """

  alias __MODULE__.Event
  alias __MODULE__.Config
  alias __MODULE__.Opts

  def process_event(config, %{"encrypt" => encrypted_data} = _payload, opts)
      when is_map(config) do
    config = Config.validate_config!(config)
    opts = Opts.validate_opts!(opts, config)

    encrypt_key = config.encrypt_key

    unless encrypt_key do
      raise RuntimeError, "decrypting encrypted event requires config :encrypt_key"
    end

    with :ok <- pre_verify_event(config, opts),
         {:ok, raw_json} <- decrypt_event(encrypt_key, encrypted_data),
         {:ok, payload} <- Jason.decode(raw_json),
         :ok <- post_verify_event(config, opts, payload) do
      respond(payload)
    end
  end

  def process_event(config, payload, opts) when is_map(config) do
    with :ok <- post_verify_event(config, opts, payload) do
      respond(payload)
    end
  end

  defp pre_verify_event(
         %Config{encrypt_key: encrypt_key},
         %Opts{security_verification_method: {:signature, factors}}
       ) do
    verify_event_with_signature(encrypt_key, factors)
  end

  defp pre_verify_event(%Config{}, %Opts{}), do: :ok

  defp post_verify_event(
         %Config{verification_token: verification_token},
         %Opts{security_verification_method: :verification_token},
         %{"type" => "url_verification", "token" => event_verification_token} = _payload
       ) do
    verify_event_with_verification_token(verification_token, event_verification_token)
  end

  defp post_verify_event(
         %Config{verification_token: verification_token},
         %Opts{security_verification_method: :verification_token},
         %{"schema" => "2.0", "header" => %{"token" => event_verification_token}} = _payload
       ) do
    verify_event_with_verification_token(verification_token, event_verification_token)
  end

  defp post_verify_event(%Config{}, %Opts{}, _payload), do: :ok

  defp verify_event_with_verification_token(verification_token, event_verification_token) do
    if verification_token == event_verification_token,
      do: :ok,
      else: {:error, :bad_verification_token}
  end

  defp verify_event_with_signature(encrypt_key, event_signature_factors) do
    %{
      raw_body: raw_body,
      timestamp: timestamp,
      nonce: nonce,
      signature: signature
    } = event_signature_factors

    content = timestamp <> nonce <> encrypt_key <> raw_body

    if :crypto.hash(:sha256, content) == signature,
      do: :ok,
      else: {:error, :bad_signature}
  end

  @doc false
  def decrypt_event(encrypt_key, encrypted_data) when is_binary(encrypted_data) do
    key = :crypto.hash(:sha256, encrypt_key)
    <<iv::binary-size(16), encrypted_event::binary>> = Base.decode64!(encrypted_data)

    case :crypto.crypto_one_time(:aes_256_cbc, key, iv, encrypted_event,
           encrypt: false,
           padding: :pkcs_padding
         ) do
      result when is_binary(result) -> {:ok, result}
      other -> other
    end
  end

  defp respond(%{
         "type" => "url_verification",
         "challenge" => challenge
       }) do
    {:ok, %{challenge: challenge}}
  end

  defp respond(%{"schema" => "2.0", "header" => header, "event" => event_content}) do
    %{
      "event_id" => event_id,
      "event_type" => event_type,
      "create_time" => create_time,
      "tenant_key" => tenant_key,
      "app_id" => app_id
    } = header

    {:ok,
     Event.new(%{
       id: event_id,
       type: event_type,
       content: event_content,
       created_at: convert_timestamp_to_datetime(create_time),
       meta: %{
         tenant_key: tenant_key,
         app_id: app_id
       }
     })}
  end

  defp respond(other) do
    other
  end

  defp convert_timestamp_to_datetime(timestamp) when is_binary(timestamp) do
    timestamp
    |> String.to_integer()
    |> DateTime.from_unix!(:millisecond)
  end
end
