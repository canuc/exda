defmodule Exda.MixProject do
  use Mix.Project

  def project do
    [
      app: :exda,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        # The main page in the docs
        main: "Exda",
        logo: "priv/exda_logo.png",
        extras: ["README.md"]
      ],
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def package() do
    [
      links: %{"GitHub" => "https://github.com/canuc/exda"},
      description: "EDA for the masses, easily decouple your elixir contexts.",
      licenses: ["Apache 2.0"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Tools
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.5.7", only: :test, runtime: false}
    ]
  end
end
