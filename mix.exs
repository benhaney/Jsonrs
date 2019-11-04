defmodule Jsonrs.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :jsonrs,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      compilers: [:rustler] ++ Mix.compilers(),
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
      {:rustler, "~> 0.21.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
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
      files: ["lib", "mix.exs", "README*", "native/jsonrs/src", "native/jsonrs/Cargo.toml"]
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
