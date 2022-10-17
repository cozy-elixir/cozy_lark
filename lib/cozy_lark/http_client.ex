defmodule CozyLark.HTTPClient do
  @finch_name __MODULE__

  def request_json(method, url, headers \\ %{}, query_params \\ %{}, body_params \\ %{}) do
    Finch.build(method, url)
    |> set_header("content-type", "application/json; charset=utf-8")
    |> set_headers(headers)
    |> set_query_params(query_params)
    |> set_body_params(body_params)
    |> Finch.request(@finch_name)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: status, body: body}} when status >= 400 and status < 500 ->
        {:error, {:client_error, Jason.decode!(body)}}

      {:ok, %Finch.Response{status: status, body: body}} when status >= 500 ->
        {:error, {:server_error, Jason.decode!(body)}}

      {:error, error} ->
        {:error, error}
    end
  end

  def set_headers(%Finch.Request{} = req, headers) when is_map(headers) do
    Enum.reduce(headers, req, fn {name, value}, acc ->
      set_header(acc, name, value)
    end)
  end

  def set_header(%Finch.Request{headers: headers} = req, name, value)
      when is_binary(name) and is_binary(value) do
    name = String.downcase(name)
    %{req | headers: List.keystore(headers, name, 0, {name, value})}
  end

  def set_query_params(%Finch.Request{query: query} = req, query_params)
      when is_map(query_params) do
    new_query =
      (query || "")
      |> URI.decode_query()
      |> Map.merge(query_params)
      |> URI.encode_query()

    %{req | query: new_query}
  end

  def set_body_params(%Finch.Request{method: "GET"} = req, _body_params) do
    %{req | body: nil}
  end

  def set_body_params(%Finch.Request{} = req, body_params) when map_size(body_params) == 0 do
    %{req | body: nil}
  end

  def set_body_params(%Finch.Request{} = req, body_params) when is_map(body_params) do
    %{req | body: Jason.encode!(body_params)}
  end
end
