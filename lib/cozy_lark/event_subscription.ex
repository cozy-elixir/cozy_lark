defmodule CozyLark.EventSubscription do
  @moduledoc """
  Provides utilities of handling event subscriptions.

  + resolving the challenge request when configuring the request URL.
  + transforming V2.0 events into `CozyLark.EventSubscription.Event`.

  Read more at [Subscribe to events](https://open.feishu.cn/document/ukTMukTMukTM/uUTNz4SN1MjL1UzM).

  > #### WARNING {: .warning}
  >
  > Only the V2.0 events are supported.

  ## Basic concepts

  ### the process of subscription

  1. setup `verification_token` and `encrypt_key`
  2. configure the request URL
  3. add events
  4. apply for scopes
  5. receive and process events

  Utilities provided by this module can be used at:

  + step 2
  + step 5

  ### supported events

  The full list of events can be found at
  [Getting Started - Event list](https://open.feishu.cn/document/ukTMukTMukTM/uYDNxYjL2QTM24iN0EjN/event-list).

  ## Usage

      defmodule Demo.EventHandler do
        alias CozyLark.EventSubscription
        alias CozyLark.EventSubscription.Config

        def process_event(payload) do
          EventSubscription.receive_event(config(), payload,
            security_verification_method: :verification_token
          )
        end

        def config() do
          :demo
          |> Application.fetch_env!(__MODULE__)
          |> Enum.into(%{})
          |> Config.new!()
        end

      end

      # config/runtime.exs
      config :demo, Demo.EventHandler,
        verification_token: System.fetch_env!("FEISHU_EVENT_SUBSCRIPTION_VERIFICATION_TOKEN")
        encrypt_key: System.fetch_env!("FEISHU_EVENT_SUBSCRIPTION_ENCRYPT_KEY")

  ## More details

  + [Event processing method - Security verification](https://open.feishu.cn/document/ukTMukTMukTM/uYDNxYjL2QTM24iN0EjN/event-subscription-configure-/encrypt-key-encryption-configuration-case?lang=en-US#d41e8916).
  + [Event processing method - Event decryption](https://open.feishu.cn/document/ukTMukTMukTM/uYDNxYjL2QTM24iN0EjN/event-subscription-configure-/encrypt-key-encryption-configuration-case?lang=en-US#58c980bc).

  """

  alias __MODULE__.Event
  alias __MODULE__.Config
  alias __MODULE__.Opts

  @type payload() :: map()
  @type response() ::
          {:ok, {:challenge, String.t()}}
          | {:ok, {:event, Event.t()}}
          | {:error, {:unknown_event, term()}}
          | {:error, :bad_verification_token}
          | {:error, :bad_signature}

  @spec receive_event(Config.t(), payload(), Opts.opts()) :: response()
  def receive_event(%Config{} = config, %{"encrypt" => encrypted_data} = _payload, opts) do
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

  def receive_event(config, payload, opts) when is_map(config) do
    opts = Opts.validate_opts!(opts, config)

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
    try do
      key = :crypto.hash(:sha256, encrypt_key)
      <<iv::binary-size(16), encrypted_event::binary>> = Base.decode64!(encrypted_data)

      result =
        :crypto.crypto_one_time(:aes_256_cbc, key, iv, encrypted_event,
          encrypt: false,
          padding: :pkcs_padding
        )

      {:ok, result}
    rescue
      _ -> :error
    end
  end

  defp respond(%{
         "type" => "url_verification",
         "challenge" => challenge
       }) do
    {:ok, {:challenge, challenge}}
  end

  defp respond(%{"schema" => "2.0", "header" => header, "event" => event_content}) do
    %{
      "event_id" => event_id,
      "event_type" => event_type,
      "create_time" => create_time,
      "tenant_key" => tenant_key,
      "app_id" => app_id
    } = header

    event =
      Event.new(%{
        id: event_id,
        type: event_type,
        content: event_content,
        created_at: convert_timestamp_to_datetime(create_time),
        meta: %{
          tenant_key: tenant_key,
          app_id: app_id
        }
      })

    {:ok, {:event, event}}
  end

  defp respond(other) do
    {:error, {:unknown_event, other}}
  end

  defp convert_timestamp_to_datetime(timestamp) when is_binary(timestamp) do
    timestamp
    |> String.to_integer()
    |> DateTime.from_unix!(:millisecond)
  end
end
