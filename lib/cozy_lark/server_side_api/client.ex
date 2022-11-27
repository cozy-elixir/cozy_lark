defmodule CozyLark.ServerSideAPI.Client do
  @moduledoc """
  Specification for the HTTP client of CozyLark.ServerSideAPI.

  It can be set to a client provided by CozyLark, such as:

      config :cozy_lark, :server_side_api_client, CozyLark.ServerSideAPI.Client.Finch

  Or, set it to your own client, such as:

      config :cozy_lark, :server_side_api_client, MyClient

  """

  alias CozyLark.ServerSideAPI.Request

  @type status :: pos_integer()
  @type headers :: [{binary(), binary()}]
  @type body :: map()

  @typedoc """
  The response of a request.
  """
  @type response() :: {:ok, status, headers, body} | {:error, term()}

  @doc """
  Callback to initialize the given API client.
  """
  @callback init() :: :ok

  @doc """
  Callback to send a request.
  """
  @callback request(Request.t()) :: response()

  @optional_callbacks init: 0

  @doc false
  def init do
    client = api_client()

    if Code.ensure_loaded?(client) and function_exported?(client, :init, 0) do
      :ok = client.init()
    end

    :ok
  end

  @doc """
  Send a struct `%CozyLark.ServerSideAPI.Request{}` as an HTTP request by the given client.
  """
  @spec request(Request.t()) :: response()
  def request(%Request{} = req) do
    req
    |> api_client().request()
    |> maybe_to_map()
  end

  defp maybe_to_map({:ok, status, headers, body} = response) do
    case List.keyfind(headers, "content-type", 0) do
      {"content-type", "application/json" <> _} ->
        {:ok, status, headers, decode_json!(body)}

      _ ->
        response
    end
  end

  defp maybe_to_map(response), do: response

  defp decode_json!(content), do: CozyLark.json_library().decode!(content)

  defp api_client do
    Application.fetch_env!(:cozy_lark, :server_side_api_client)
  end
end
