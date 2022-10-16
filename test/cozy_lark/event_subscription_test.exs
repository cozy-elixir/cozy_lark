defmodule CozyLark.EventSubscriptionTest do
  use ExUnit.Case
  alias CozyLark.EventSubscription

  describe "validate_config_and_opts!/2" do
    test "checks config - the default value of option :security_verification_method is :verification_token" do
      {_config, opts} =
        EventSubscription.validate_config_and_opts!(
          %{verification_token: "example_verification_token"},
          []
        )

      assert %{security_verification_method: :verification_token} = opts
    end

    test "checks config - option [security_verification_method: :verification_token] requires config :verification_token" do
      assert_raise ArgumentError,
                   "option [security_verification_method: :verification_token] requires config :verfication_token",
                   fn ->
                     EventSubscription.validate_config_and_opts!(%{},
                       security_verification_method: :verification_token
                     )
                   end
    end

    test "checks config - option [security_verification_method: :signature] requires config :verification_token and :encrypt_key" do
      assert_raise ArgumentError,
                   "option [security_verification_method: {:signature, _}] requires config :verfication_token and :encrypt_key",
                   fn ->
                     EventSubscription.validate_config_and_opts!(%{},
                       security_verification_method:
                         {:signature,
                          %{
                            raw_body: "example_raw_body",
                            timestamp: "example_timestamp",
                            nonce: "example_nonce",
                            signature: "example_signature"
                          }}
                     )
                   end
    end

    test "check option - option [security_verification_method: {:signature, factors}] requires the factors to be a map with following keys" do
      message =
        String.trim(~s"""
        option [security_verification_method: {:signature, factors}] requires the factors to be a map with following keys:
        + raw_body
        + timestamp
        + nonce
        + signature
        """)

      assert_raise ArgumentError,
                   message,
                   fn ->
                     EventSubscription.validate_config_and_opts!(
                       %{
                         verification_token: "example_verification_token",
                         encrypt_key: "example_encrypt_key"
                       },
                       security_verification_method: {:signature, %{raw_body: "example_raw_body"}}
                     )
                   end
    end

    test "works as expected for [security_verification_method: :verification_token]" do
      {config, opts} =
        EventSubscription.validate_config_and_opts!(
          %{verification_token: "example_verification_token"},
          security_verification_method: :verification_token
        )

      assert %{verification_token: "example_verification_token"} = config
      assert %{security_verification_method: :verification_token} = opts
    end

    test "works as expected for [security_verification_method: :signature]" do
      {config, opts} =
        EventSubscription.validate_config_and_opts!(
          %{
            verification_token: "example_verification_token",
            encrypt_key: "example_encrypt_key"
          },
          security_verification_method:
            {:signature,
             %{
               raw_body: "example_raw_body",
               timestamp: "example_timestamp",
               nonce: "example_nonce",
               signature: "example_signature"
             }}
        )

      assert %{
               verification_token: "example_verification_token",
               encrypt_key: "example_encrypt_key"
             } = config

      assert %{
               security_verification_method:
                 {:signature,
                  %{
                    raw_body: "example_raw_body",
                    timestamp: "example_timestamp",
                    nonce: "example_nonce",
                    signature: "example_signature"
                  }}
             } = opts
    end
  end

  test "decrypt_event/2" do
    encrypt_key = "test key"
    encrypted_content = "P37w+VZImNgPEO1RBhJ6RtKl7n6zymIbEG1pReEzghk="
    assert {:ok, "hello world"} = EventSubscription.decrypt_event(encrypt_key, encrypted_content)
  end
end
