defmodule ApiAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :api_auth,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:calendar, "~> 0.17"},
    ]
  end
end
