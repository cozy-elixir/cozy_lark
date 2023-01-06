defmodule CozyLark.EventSubscription.Event do
  @enforce_keys [
    :id,
    :type,
    :content,
    :created_at,
    :meta
  ]

  defstruct @enforce_keys

  @type args() :: %{
          id: String.t(),
          type: String.t(),
          content: map(),
          created_at: DateTime.t(),
          meta: map()
        }

  @type t :: %__MODULE__{
          id: String.t(),
          type: String.t(),
          content: map(),
          created_at: DateTime.t(),
          meta: map()
        }

  @spec new(args()) :: t()
  def new(args) do
    struct(__MODULE__, args)
  end
end
