defmodule Jsonrs.MixProject do
  use Mix.Project

  @version "0.3.3"

  def project do
    [
      app: :jsonrs,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/benhaney/jsonrs"
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
      {:rustler_precompiled, "~> 0.7.0"},
      {:rustler, "~> 0.30.0", optional: true, runtime: false},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
    ]
  end

  defp description() do
    """
    A fully-featured and performant JSON library powered by Rust
    """
  end

  defp package() do
    [
      maintainers: ["Ben Haney"],
      licenses: ["Unlicense"],
      links: %{"GitHub" => "https://github.com/benhaney/jsonrs"},
      files: ["lib", "mix.exs", "README*", "native/jsonrs/src", "native/jsonrs/.cargo", "native/jsonrs/README*", "native/jsonrs/Cargo*", "checksum-*.exs"]
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "Jsonrs",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/jsonrs",
      source_url: "https://github.com/benhaney/jsonrs",
      extras: [
        "README.md"
      ]
    ]
  end
end
