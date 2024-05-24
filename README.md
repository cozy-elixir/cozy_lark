> This package is not maintained. Considering that my former employers might still be using it, the repository will not be cleaned up, only archived.

# CozyLark

[![CI](https://github.com/cozy-elixir/cozy_lark/actions/workflows/ci.yml/badge.svg)](https://github.com/cozy-elixir/cozy_lark/actions/workflows/ci.yml) [![Hex.pm](https://img.shields.io/hexpm/v/cozy_lark.svg)](https://hex.pm/packages/cozy_lark)

> An SDK builder for [Lark](https://www.larksuite.com/) Open Platform / [Feishu](https://www.feishu.cn/) Open Platform.

This package is an SDK builder. It provides utilities to reduce the cost of creating an SDK, such as:

- building server-side API requests
- handling event subscriptions
- getting access tokens
- converting the JSON string in the response to a map
- ...

## Installation

Add `cozy_lark` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cozy_lark, "~> <version>"}
  ]
end
```

For more information, see the doc of [CozyLark](https://hexdocs.pm/cozy_lark/CozyLark.html) module.

# License

Apache License 2.0
