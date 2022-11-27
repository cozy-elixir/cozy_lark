defmodule CozyLark.ServerSideAPI.Request do
  @moduledoc """

  """

  defstruct [
    :scheme,
    :host,
    :port,
    :method,
    :path,
    :query,
    :headers,
    :body,
    meta: %{},
    private: %{}
  ]

  @typedoc """
  The request scheme.
  """
  @type scheme() :: String.t()

  @typedoc """
  The request method.
  """
  @type method() :: String.t()

  @typedoc """
  The request path.
  """
  @type path() :: String.t()

  @typedoc """
  The optional request query.
  """
  @type query() :: %{
          optional(query_name :: String.t()) => query_value :: boolean() | number() | String.t()
        }

  @typedoc """
  The request headers.
  """
  @type headers() :: %{optional(header_name :: String.t()) => header_value :: String.t()}

  @typedoc """
  The optional request body.
  """
  @type body() :: map() | nil

  @typedoc """
  The request metadata.
  """
  @type meta() :: %{optional(atom()) => term()}

  @typedoc """
  The request private information, which is useful for passing data to other modules.
  """
  @type private() :: %{optional(atom()) => term()}

  @type t :: %__MODULE__{
          scheme: scheme(),
          host: String.t(),
          port: :inet.port_number(),
          method: method(),
          path: path(),
          query: query(),
          headers: headers(),
          body: body(),
          meta: meta(),
          private: private()
        }

  alias CozyLark.ServerSideAPI.Config
  alias CozyLark.ServerSideAPI.Spec

  @doc """
  Builds a request from a config and an spec.
  """
  @spec build!(Config.t(), Spec.t()) :: t()
  def build!(%Config{} = config, %Spec{} = spec) do
    build_request(config, spec)
    |> set_header_lazy("content-type", fn -> "application/json; charset=utf-8" end)
  end

  defp build_request(config, spec) do
    %{
      scheme: scheme,
      host: host,
      port: port,
      path: path_prefix
    } =
      config.platform
      |> fetch_base_url!()
      |> parse_base_url()

    %{
      access_token_type: access_token_type,
      method: method,
      path: path,
      query: query,
      headers: headers,
      body: body
    } = spec

    %__MODULE__{
      scheme: scheme,
      host: host,
      port: port,
      method: method,
      path: Path.join(path_prefix, path),
      query: query,
      headers: headers,
      body: body,
      meta: %{
        access_token_type: access_token_type
      },
      private: %{
        config: config
      }
    }
  end

  @base_urls %{
    lark: "https://open.larksuite.com/open-apis",
    feishu: "https://open.feishu.cn/open-apis"
  }
  defp fetch_base_url!(platform) do
    Map.fetch!(@base_urls, platform)
  end

  defp parse_base_url(url) when is_binary(url) do
    url
    |> URI.parse()
    |> Map.take([:scheme, :host, :port, :path])
  end

  @doc false
  def set_header(%__MODULE__{} = req, name, value)
      when is_binary(name) and is_binary(value) do
    name = String.downcase(name)
    new_headers = Map.put(req.headers, name, value)
    %{req | headers: new_headers}
  end

  @doc false
  def set_header_lazy(%__MODULE__{} = req, name, fun)
      when is_binary(name) and is_function(fun, 0) do
    name = String.downcase(name)
    new_headers = Map.put_new_lazy(req.headers, name, fun)
    %{req | headers: new_headers}
  end
end
