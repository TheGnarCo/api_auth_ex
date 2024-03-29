defmodule ApiAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :api_auth,
      version: "0.4.0",
      elixir: "~> 1.14.0",
      description: "HMAC API Authentication",
      source_url: "https://github.com/TheGnarCo/api_auth_ex/",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:timex, "~> 3.7.9"},
      {:plug_crypto, "~> 1.0"},
      {:credo, "~> 1.6.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false}
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
