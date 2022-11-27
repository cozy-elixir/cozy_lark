defmodule CozyLark.ServerSideAPITest do
  use ExUnit.Case
  alias CozyLark.ServerSideAPI
  alias CozyLark.ServerSideAPI.Config

  defmodule GroupManager do
    @moduledoc """
    An example module provides basic API to manage groups.
    """

    alias CozyLark.ServerSideAPI
    alias CozyLark.ServerSideAPI.Config

    def list_groups() do
      config()
      |> ServerSideAPI.build!(%{
        access_token_type: :tenant_access_token,
        method: "GET",
        path: "/im/v1/chats"
      })
      |> ServerSideAPI.request()
    end

    defp config() do
      :demo
      |> Application.fetch_env!(__MODULE__)
      |> Enum.into(%{})
      |> Config.new!()
    end
  end

  setup do
    Application.put_env(:demo, __MODULE__.GroupManager,
      platform: :feishu,
      app_type: :custom_app,
      app_id: System.fetch_env!("COZY_LARK_APP_ID"),
      app_secret: System.fetch_env!("COZY_LARK_APP_SECRET")
    )

    :ok
  end

  describe "an exmaple SDK - GroupManager" do
    test "lists groups" do
      assert {:ok, 200, _header, %{"code" => 0}} = GroupManager.list_groups()
    end
  end
end
