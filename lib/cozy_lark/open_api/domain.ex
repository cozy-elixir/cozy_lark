defmodule CozyLark.OpenAPI.Domain do
  def build_url!(domain, path) do
    domain
    |> fetch_base_url!()
    |> Path.join(path)
  end

  def fetch_base_url!(domain) do
    urls = %{
      lark: "https://open.larksuite.com/open-apis",
      feishu: "https://open.feishu.cn/open-apis"
    }

    Map.fetch!(urls, domain)
  end
end
