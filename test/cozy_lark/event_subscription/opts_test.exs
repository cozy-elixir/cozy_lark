defmodule CozyLark.EventSubscription.OptsTest do
  use ExUnit.Case
  alias CozyLark.EventSubscription.Config
  alias CozyLark.EventSubscription.Opts

  describe "validate_opts!/2" do
    test "checks opts - option :security_verification_method is missing" do
      config = Config.new!(%{})

      assert_raise ArgumentError,
                   "unknown value of option :security_verification_method - nil",
                   fn ->
                     Opts.validate_opts!(
                       [],
                       config
                     )
                   end
    end

    test "checks config - option [security_verification_method: :verification_token] requires config :verification_token" do
      config = Config.new!(%{})

      assert_raise ArgumentError,
                   "option [security_verification_method: :verification_token] requires config :verfication_token",
                   fn ->
                     Opts.validate_opts!(
                       [security_verification_method: :verification_token],
                       config
                     )
                   end
    end

    test "checks config - option [security_verification_method: :signature] requires config :verification_token and :encrypt_key" do
      config = Config.new!(%{})

      assert_raise ArgumentError,
                   "option [security_verification_method: {:signature, _}] requires config :verfication_token and :encrypt_key",
                   fn ->
                     Opts.validate_opts!(
                       [
                         security_verification_method:
                           {:signature,
                            %{
                              raw_body: "example_raw_body",
                              timestamp: "example_timestamp",
                              nonce: "example_nonce",
                              signature: "example_signature"
                            }}
                       ],
                       config
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

      config =
        Config.new!(%{
          verification_token: "example_verification_token",
          encrypt_key: "example_encrypt_key"
        })

      assert_raise ArgumentError,
                   message,
                   fn ->
                     Opts.validate_opts!(
                       [
                         security_verification_method:
                           {:signature, %{raw_body: "example_raw_body"}}
                       ],
                       config
                     )
                   end
    end

    test "works as expected for [security_verification_method: :verification_token]" do
      config =
        Config.new!(%{
          verification_token: "example_verification_token"
        })

      opts = Opts.validate_opts!([security_verification_method: :verification_token], config)
      assert %Opts{security_verification_method: :verification_token} = opts
    end

    test "works as expected for [security_verification_method: :signature]" do
      config =
        Config.new!(%{
          verification_token: "example_verification_token",
          encrypt_key: "example_encrypt_key"
        })

      opts =
        Opts.validate_opts!(
          [
            security_verification_method:
              {:signature,
               %{
                 raw_body: "example_raw_body",
                 timestamp: "example_timestamp",
                 nonce: "example_nonce",
                 signature: "example_signature"
               }}
          ],
          config
        )

      assert %Opts{
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
end
