defmodule CozyLark.ServerSideAPI.ConfigTest do
  use ExUnit.Case
  alias CozyLark.ServerSideAPI.Config

  describe "new!/1" do
    test "creates a %Config{} struct" do
      assert %Config{app_type: _, platform: _, app_id: _, app_secret: _} =
               Config.new!(%{
                 platform: :lark,
                 app_type: :custom_app,
                 app_id: "...",
                 app_secret: "..."
               })
    end

    test "check invalid platform" do
      assert_raise ArgumentError,
                   "unknown value of key :platform - :luck",
                   fn ->
                     Config.new!(%{
                       platform: :luck,
                       app_type: :custom_app,
                       app_id: "...",
                       app_secret: "..."
                     })
                   end
    end

    test "check invalid app_type" do
      assert_raise ArgumentError,
                   "unknown value of key :app_type - :luck_app",
                   fn ->
                     Config.new!(%{
                       platform: :lark,
                       app_type: :luck_app,
                       app_id: "...",
                       app_secret: "..."
                     })
                   end
    end
  end
end
