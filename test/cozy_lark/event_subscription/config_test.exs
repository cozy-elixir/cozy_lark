defmodule CozyLark.EventSubscription.ConfigTest do
  use ExUnit.Case
  alias CozyLark.EventSubscription.Config

  describe "new!/1" do
    test "works as expected" do
      assert %Config{verification_token: "...", encrypt_key: "..."} =
               Config.new!(%{verification_token: "...", encrypt_key: "..."})
    end

    test "accepts optional verification_token" do
      assert %Config{verification_token: nil, encrypt_key: "..."} =
               Config.new!(%{encrypt_key: "..."})

      assert %Config{verification_token: nil, encrypt_key: "..."} =
               Config.new!(%{verification_token: nil, encrypt_key: "..."})
    end

    test "accepts optional encrypt_key" do
      assert %Config{verification_token: "...", encrypt_key: nil} =
               Config.new!(%{verification_token: "..."})

      assert %Config{verification_token: "...", encrypt_key: nil} =
               Config.new!(%{verification_token: "...", encrypt_key: nil})
    end
  end
end
