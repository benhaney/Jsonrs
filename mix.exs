defmodule Jsonrs.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :jsonrs,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      rustler_crates: rustler_crates(),
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
      {:rustler, "~> 0.25.0"},
      {:rustler_precompiled, "~> 0.5"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
    ]
  end

  defp rustler_crates do
    [
      jsonrs: [path: "native/jsonrs", mode: if(Mix.env() == :prod, do: :release, else: :debug)]
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
      files: ["lib", "mix.exs", "README*", "native/jsonrs/src", "native/jsonrs/.cargo", "native/jsonrs/README*", "native/jsonrs/Cargo*", "native", "checksum-*.exs"]
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
