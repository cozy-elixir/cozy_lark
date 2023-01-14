defmodule CozyLark.EventSubscription.Event do
  @moduledoc """
  Provides the struct for shaping events.
  """

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

  @doc """
  Creates a event from a given map.
  """
  @spec new(args()) :: t()
  def new(args) do
    struct(__MODULE__, args)
  end
end
