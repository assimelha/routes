defmodule Routes.MixProject do
  use Mix.Project

  def project do
    [
      app: :routes,
      version: "0.2.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "Automatically generate type-safe JavaScript and TypeScript route helpers from your Phoenix router, ensuring client-side routing stays in sync with your Phoenix routes",
      package: package(),
      source_url: "https://github.com/assimelha/routes",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7.0", optional: true},
      {:jason, "~> 1.4", optional: true},
      {:file_system, "~> 1.0"},
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Assim Elhammouti"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/assimelha/routes"},
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE.md)
    ]
  end
end
