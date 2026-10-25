defmodule TermHive.MixProject do
  use Mix.Project
  def project do
    [
      app: :termhive,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: TermHive.CLI],
      deps: []
    ]
  end
  def application do
    [extra_applications: [:logger]]
  end
end
