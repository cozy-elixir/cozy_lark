defmodule CozyLark.ServerSideAPI.Client.Finch do
  @moduledoc """
  Finch-based HTTP client for CozyLark.ServerSideAPI.

      config :cozy_lark, :server_side_api_client, CozyLark.ServerSideAPI.Client.Finch

  In order to use `Finch` API client, you must start `Finch` and provide a `:name`.
  Often in your supervision tree:

      children = [
        {Finch, name: CozyLark.Finch}
      ]

  Or, in rare cases, dynamically:

      Finch.start_link(name: CozyLark.Finch)

  If a name different from `CozyLark.Finch` is used, or you want to use an existing Finch instance,
  you can provide the name via the config:

      config :cozy_lark,
        server_side_api_client: CozyLark.ServerSideAPI.Client.Finch
        finch_name: My.Custom.Name

  """

  require Logger
  alias CozyLark.ServerSideAPI.Request

  @behaviour CozyLark.ServerSideAPI.Client

  @impl true
  def init do
    unless Code.ensure_loaded?(Finch) do
      Logger.error("""
      Could not find finch dependency.

      Please add :finch to your dependencies:

          {:finch, "~> 0.13"}

      Or set your own CozyLark.ServerSideAPI.Client:

          config :cozy_lark, :server_side_api_client, MyClient

      """)

      raise "missing finch dependency"
    end

    _ = Application.ensure_all_started(:finch)
    :ok
  end

  @impl true
  def request(%Request{} = req) do
    method = build_method(req)
    url = build_url(req)
    headers = build_headers(req)
    body = build_body(req)

    request = Finch.build(method, url, headers, body)

    case Finch.request(request, finch_name()) do
      {:ok, response} ->
        {:ok, response.status, response.headers, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_method(req), do: req.method

  defp build_url(req) do
    query = encode_query(req.query)

    %URI{
      scheme: req.scheme,
      host: req.host,
      port: req.port,
      path: req.path,
      query: query
    }
    |> URI.to_string()
  end

  defp encode_query(query) when query == %{}, do: nil
  defp encode_query(query) when is_map(query), do: URI.encode_query(query)

  defp build_headers(req) do
    Enum.map(req.headers, fn {k, v} ->
      {to_string(k), to_string(v)}
    end)
  end

  defp build_body(req), do: encode_json(req.body)

  defp encode_json(nil), do: nil
  defp encode_json(content), do: CozyLark.json_library().encode!(content)

  defp finch_name do
    Application.get_env(:cozy_lark, :finch_name, CozyLark.Finch)
  end
end
