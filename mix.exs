defmodule ApiAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :api_auth,
      version: "0.4.0",
      elixir: "~> 1.14.0",
      description: "HMAC API Authentication",
      source_url: "https://github.com/TheGnarCo/api_auth_ex/",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:calendar, "~> 1.0"},
      {:secure_compare, "~> 0.0.2"},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
    ]
  end

  defp package do
    [
      name: :api_auth,
      maintainers: ["zfletch"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/TheGnarCo/api_auth_ex/"}
    ]
  end
end
