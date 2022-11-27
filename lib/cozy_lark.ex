defmodule CozyLark do
  @moduledoc """
  An SDK builder of Lark Open Platform / Feishu Open Platform.

  Developing Lark application is all about:

  + server-side API calling
  + event subscription

  `CozyLark` provides support for above processes by following modules:

  + `CozyLark.ServerSideAPI`
  + `CozyLark.EventSubscription`
  """

  @doc false
  def json_library, do: Application.fetch_env!(:cozy_lark, :json_library)
end
