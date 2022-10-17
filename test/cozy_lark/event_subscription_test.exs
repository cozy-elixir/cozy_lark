defmodule CozyLark.EventSubscriptionTest do
  use ExUnit.Case
  alias CozyLark.EventSubscription

  test "decrypt_event/2" do
    encrypt_key = "test key"
    encrypted_content = "P37w+VZImNgPEO1RBhJ6RtKl7n6zymIbEG1pReEzghk="
    assert {:ok, "hello world"} = EventSubscription.decrypt_event(encrypt_key, encrypted_content)
  end
end
