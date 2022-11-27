defmodule CozyLark.ServerSideAPI.ConfigTest do
  use ExUnit.Case
  alias CozyLark.ServerSideAPI.Config

  describe "new!/1" do
    test "creates an %Config{} struct" do
      assert %Config{app_id: _, app_secret: _, app_type: _, domain: _} =
               Config.new!(%{
                 app_id: "...",
                 app_secret: "...",
                 app_type: :custom_app,
                 domain: :lark
               })
    end
  end
end
