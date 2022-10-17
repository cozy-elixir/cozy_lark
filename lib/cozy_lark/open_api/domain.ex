defmodule CozyLark.OpenAPI.Domain do
  def fetch_base_url!(domain) do
    urls = %{
      lark: "https://open.larksuite.com/open-apis",
      feishu: "https://open.feishu.cn/open-apis"
    }

    Map.fetch!(urls, domain)
  end
end
