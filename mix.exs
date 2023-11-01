defmodule OpenApiSpexSchemax.MixProject do
  use Mix.Project

  @vsn "0.0.1"

  def project do
    [
      app: :open_api_spex_schemax,
      description: "OpenApiSpex Schema macro library",
      version: @vsn,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, ">= 1.0.0"},
      {:open_api_spex, ">= 3.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{}
    ]
  end
end
