defmodule Jsonrs do
  @moduledoc """
  A JSON library powered by Rust's Serde through a NIF
  """

  source_url = Mix.Project.config()[:source_url]
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled, otp_app: :jsonrs,
    base_url: "#{source_url}/releases/download/v#{version}",
    force_build: System.get_env("FORCE_JSONRS_BUILD") in ["1", "true"],
    targets: RustlerPrecompiled.Config.default_targets() ++ ["aarch64-unknown-linux-musl"],
    version: version

  @spec nif_encode!(term) :: String.t()
  defp nif_encode!(_input), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_encode_pretty!(term, non_neg_integer) :: String.t()
  defp nif_encode_pretty!(_input, _indent), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_decode!(String.t()) :: term
  defp nif_decode!(_input), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Generates JSON corresponding to `input`.

  ## Examples

      iex> Jsonrs.encode(%{"x" => [1,2]})
      {:ok, "{\\"x\\":[1,2]}"}

      iex> Jsonrs.encode("\\xFF")
      {:error, :encode_error}
  """
  @spec encode(term, keyword) :: {:ok, String.t()} | {:error, :encode_error}
  def encode(input, opts \\ []) do
    {:ok, encode!(input, opts)}
  rescue
    e in ErlangError -> {:error, e.original}
  end

  @doc """
  Parses a JSON value from `input` string.

  ## Examples

      iex> Jsonrs.decode("{\\"x\\":[1,2]}")
      {:ok, %{"x" => [1, 2]}}

      iex> Jsonrs.decode("invalid")
      {:error, "expected value at line 1 column 1"}
  """
  @spec decode(String.t(), Keyword.t()) :: {:ok, term} | {:error, String.t()}
  def decode(input, opts \\ []) do
    {:ok, decode!(input, opts)}
  rescue
    e in ErlangError -> {:error, e.original}
  end

  @doc """
  Generates JSON corresponding to `input`.

  Similar to `encode/1` except it will raise in case of errors.

  ## Examples

      iex> Jsonrs.encode!(%{"x" => [1,2]})
      "{\\"x\\":[1,2]}"

      iex> Jsonrs.encode!("\\xFF")
      ** (ErlangError) Erlang error: :encode_error
  """
  @spec encode!(term, keyword) :: String.t()
  def encode!(input, opts \\ []) do
    {lean, opts} = Keyword.pop(opts, :lean, false)
    {indent, _opts} = Keyword.pop(opts, :pretty, -1)
    indent = if true == indent, do: 2, else: indent
    case lean do
      true -> input
      false -> Jsonrs.Encoder.encode(input)
    end
    |> do_encode!(indent)
  end

  defp do_encode!(input, indent) when is_integer(indent) and indent >= 0, do: nif_encode_pretty!(input, indent)
  defp do_encode!(input, _indent), do: nif_encode!(input)

  @doc """
  Parses a JSON value from `input` string.

  Similar to `decode/2` except it will raise in case of errors.

  ## Examples

      iex> Jsonrs.decode!("{\\"x\\":[1,2]}")
      %{"x" => [1, 2]}

      iex> Jsonrs.decode!("invalid")
      ** (ErlangError) Erlang error: "expected value at line 1 column 1"
  """
  @spec decode!(String.t(), Keyword.t()) :: term
  def decode!(input, _opts \\ []), do: nif_decode!(input)

  @doc """
  Identical to `encode/1`. Exists to implement Phoenix interface and encodes to a single normal string.
  """
  @spec encode_to_iodata(term, keyword) :: {:ok, String.t()} | {:error, :encode_error}
  def encode_to_iodata(input, opts \\ []), do: encode(input, opts)

  @doc """
  Identical to `encode!/1`. Exists to implement Phoenix interface and encodes to a single normal string.
  """
  @spec encode_to_iodata!(term, keyword) :: String.t()
  def encode_to_iodata!(input, opts \\ []), do: encode!(input, opts)
end
