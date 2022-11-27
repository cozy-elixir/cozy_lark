defmodule CozyLark.ServerSideAPI.SpecTest do
  use ExUnit.Case
  alias CozyLark.ServerSideAPI.Spec

  describe "build!/1" do
    test "creates an %Spec{} struct" do
      assert %Spec{access_token_type: _, method: _, path: _, query: _, headers: _, body: _} =
               Spec.build!(%{
                 access_token_type: :app_access_token,
                 method: "GET",
                 path: "/"
               })
    end

    test "raises ArgumentError when required keys are missing" do
      assert_raise ArgumentError,
                   "key :access_token_type, :method, :path are required",
                   fn ->
                     Spec.build!(%{})
                   end
    end

    test "raises ArgumentError when access_token_type is unknown" do
      assert_raise ArgumentError,
                   "unknown value of key :access_token_type - :unknown_access_token",
                   fn ->
                     Spec.build!(%{
                       access_token_type: :unknown_access_token,
                       method: "GET",
                       path: "/"
                     })
                   end
    end
  end
end
