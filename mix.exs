defmodule Exda.MixProject do
  use Mix.Project

  def project do
    [
      app: :exda,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        # The main page in the docs
        main: "Exda",
        logo: "priv/exda_logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package() do
    [
      links: %{"GitHub" => "https://github.com/canuc/exda"},
      description: "EDA for the masses, easily decouple your elixir components.",
      licenses: ["Apache 2.0"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end
end
