defmodule CozyLark.EventSubscription.Event do
  @enforce_keys [
    :id,
    :type,
    :content,
    :created_at,
    :meta
  ]

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          id: String.t(),
          type: String.t(),
          content: Map.t(),
          created_at: DateTime.t(),
          meta: Map.t()
        }

  def new(args) do
    struct(__MODULE__, args)
  end
end
