defmodule CozyLark.ServerSideAPI.RequestTest do
  use ExUnit.Case
  alias CozyLark.ServerSideAPI.Config
  alias CozyLark.ServerSideAPI.Spec
  alias CozyLark.ServerSideAPI.Request

  describe "build!/1" do
    test "builds a %Request{} struct" do
      config =
        Config.new!(%{
          app_id: "...",
          app_secret: "...",
          app_type: :custom_app,
          domain: :lark
        })

      spec =
        Spec.build!(%{
          access_token_type: :tenant_access_token,
          method: "POST",
          path: "/im/v1/messages",
          body: %{
            receive_id: "ou_7d8a6e6df7621556ce0d21922b676706ccs",
            msg_type: "text",
            content:
              "{\"text\":\"<at user_id=\\\"ou_155184d1e73cbfb8973e5a9e698e74f2\\\">Tom</at>  test content \"}",
            uuid: "a0d69e20-1dd1-458b-k525-dfeca4015204"
          }
        })

      %Request{
        scheme: "https",
        host: "open.larksuite.com",
        port: 443,
        method: "POST",
        path: "/open-apis/im/v1/messages",
        query: %{},
        headers: %{"content-type" => "application/json; charset=utf-8"},
        body: %{
          content:
            "{\"text\":\"<at user_id=\\\"ou_155184d1e73cbfb8973e5a9e698e74f2\\\">Tom</at>  test content \"}",
          msg_type: "text",
          receive_id: "ou_7d8a6e6df7621556ce0d21922b676706ccs",
          uuid: "a0d69e20-1dd1-458b-k525-dfeca4015204"
        },
        private: %{
          access_token_type: :tenant_access_token,
          app_id: "...",
          app_secret: "...",
          app_type: :custom_app
        },
        meta: %{}
      } = Request.build!(config, spec)
    end
  end
end
