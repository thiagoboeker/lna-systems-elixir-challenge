defmodule Calculator.MixProject do
  use Mix.Project

  def project do
    [
      app: :lna_systems,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      name: "Calculator",
      source_url: "https://github.com/thiagoboeker/lna-systems-elixir-challenge",
      docs: [
        main: "Calculator",
        source_url_pattern:
          "https://github.com/thiagoboeker/lna-systems-elixir-challenge/blob/master/%{path}#L%{line}",
        output: "docs"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:earmark, "~> 1.3", only: :dev},
      {:ex_doc, "~> 0.21", only: :dev}
    ]
  end

  defp escript() do
    [main_module: Calculator.Cli]
  end
end
