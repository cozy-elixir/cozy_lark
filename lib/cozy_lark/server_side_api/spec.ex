defmodule CozyLark.ServerSideAPI.Spec do
  @moduledoc """
  Describes the specification of a server-side API.
  """

  @enforce_keys [
    :access_token_type,
    :method,
    :path,
    :query,
    :headers,
    :body
  ]

  defstruct access_token_type: nil,
            method: nil,
            path: nil,
            query: %{},
            headers: %{},
            body: nil

  @typedoc """
  The type of access token which is used by this API.
  """
  @type access_token_type() :: :tenant_access_token | :app_access_token | :user_access_token | nil

  @typedoc """
  API method.
  """
  @type method() :: String.t()

  @typedoc """
  API path.
  """
  @type path() :: String.t()

  @typedoc """
  API query.
  """
  @type query() :: %{
          optional(query_name :: String.t()) => query_value :: boolean() | number() | String.t()
        }

  @typedoc """
  API headers.
  """
  @type headers() :: %{optional(header_name :: String.t()) => header_value :: String.t()}

  @typedoc """
  Optional API body.
  """
  @type body() :: map() | nil

  @type config() :: %{
          access_token_type: nil,
          method: method(),
          path: path(),
          query: query(),
          headers: headers(),
          body: body()
        }

  @type t :: %__MODULE__{
          access_token_type: nil,
          method: method(),
          path: path(),
          query: query(),
          headers: headers(),
          body: body()
        }

  @spec build!(config()) :: t()
  def build!(config) when is_map(config) do
    config
    |> validate_required_keys!()
    |> validate_access_token_type!()
    |> as_struct!()
  end

  defp validate_required_keys!(
         %{
           access_token_type: access_token_type,
           method: method,
           path: path
         } = config
       )
       when is_atom(access_token_type) and is_binary(method) and is_binary(path) do
    config
  end

  defp validate_required_keys!(_config) do
    raise ArgumentError,
          "key :access_token_type, :method, :path are required in a spec"
  end

  @supported_access_token_types [:tenant_access_token, :app_access_token, :user_access_token, nil]
  defp validate_access_token_type!(%{access_token_type: type} = config)
       when type in @supported_access_token_types do
    config
  end

  defp validate_access_token_type!(%{access_token_type: type}) do
    raise ArgumentError,
          "unknown value of key :access_token_type - #{inspect(type)}"
  end

  defp as_struct!(config) do
    default_struct = __MODULE__.__struct__()
    valid_keys = Map.keys(default_struct)
    config = Map.take(config, valid_keys)
    Map.merge(default_struct, config)
  end
end
