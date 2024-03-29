defmodule CozyLark do
  @moduledoc """
  An SDK builder of Lark Open Platform / Feishu Open Platform.

  Developing Lark / Feishu applications is all about:

  + calling server-side API
  + subscribing events

  `CozyLark` provides supports for above processes by following modules:

  + `CozyLark.ServerSideAPI`
  + `CozyLark.EventSubscription`

  """

  @doc false
  def json_library, do: Application.fetch_env!(:cozy_lark, :json_library)
end
