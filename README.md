# Exda

[![Build Status](https://travis-ci.org/canuc/exda.svg?branch=master)](https://travis-ci.org/canuc/exda)
[![codecov](https://codecov.io/gh/canuc/exda/branch/master/graph/badge.svg)](https://codecov.io/gh/canuc/exda)

## Porpose

This library's purpose is to allow a user to decouple components within their application via EDA.

EDA is event driven architecture, that encourages smaller more testable and easily maintainable
contexts.

This library was inspired by a talk at [ElixirConf EU 2018](https://www.youtube.com/watch?v=8qDXG7tnl9w).

This architecture also makes it possible to execute proper unit tests without having to deal with external
network requests.

For integration guide and core concepts, please read the hexdocs: [HexDocs](https://hexdocs.pm/exda/Exda.html)

## Installation

Exda can be installed by adding `exda` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exda, "~> 0.1.1"}
  ]
end
```

Documentation is available at [HexDocs](https://hexdocs.pm/exda/Exda.html)