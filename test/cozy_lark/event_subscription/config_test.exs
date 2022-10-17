defmodule CozyLark.EventSubscription.ConfigTest do
  use ExUnit.Case
  alias CozyLark.EventSubscription.Config

  describe "validate_opts!/2" do
    test "works as expected" do
      assert %Config{verification_token: _, encrypt_key: _} = Config.validate_config!(%{})
    end
  end
end
