# OpenApiSpex.Schemax

Simple DSL for OpenApiSpex.

## Installation

```elixir
def deps do
  [
    {:open_api_spex_schemax, git: "https://github.com/bangalcat/open_api_spex_schemax"}
  ]
end
```

## Examples

```elixir
defmodule SimpleUser do
  use OpenApiSpex.Schemax

  @required [:id, :name]
  schema "SimpleUser" do
    property :id, :integer
    property :name, :string
    property :is_verified, :boolean
  end
end

defmodule ListResponse do
  use OpenApiSpex.Schemax

  schema "ListResponse" do
    property :list, list()
  end

  embedded_schema :list do
    property :id, :integer
    property :name, :string
    required [:id, :name]
  end
end

```

## Disclaimer

This is very simple and rough library to generate OpenAPISpex spec from Ecto or Absithe's schema-like syntax.
It is not a complete solution and may not work for all cases. Please use it at your own risk.

I published this repo for my presentation, and I may not be able to maintain it.
