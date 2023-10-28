defmodule Jsonrs do
  @moduledoc """
  A JSON library powered by Rust's Serde through a NIF
  """

  source_url = Mix.Project.config()[:source_url]
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled, otp_app: :jsonrs,
    base_url: "#{source_url}/releases/download/v#{version}",
    force_build: System.get_env("FORCE_JSONRS_BUILD") in ["1", "true"],
    targets: RustlerPrecompiled.Config.default_targets(),
    version: version

  @type compression_algorithm :: :gzip | :none
  @type compression_level :: non_neg_integer()
  @type compression_options :: {compression_algorithm(), compression_level()}

  @spec nif_encode(term, non_neg_integer | nil, compression_options()) :: String.t()
  defp nif_encode(_input, _indent, _compression), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_decode(String.t()) :: term
  defp nif_decode(_input), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Generates JSON corresponding to `input`.

  ## Examples

      iex> Jsonrs.encode(%{"x" => [1,2]})
      {:ok, "{\\"x\\":[1,2]}"}

      iex> Jsonrs.encode("\\xFF")
      {:error, \"Expected to deserialize a UTF-8 stringable term\"}
  """
  @spec encode(term, keyword) :: {:ok, String.t()} | {:error, String.t()}
  def encode(input, opts \\ []) do
    {:ok, encode!(input, opts)}
  rescue
    e -> {:error, error_string(e)}
  end

  @doc """
  Parses a JSON value from `input` string.

  ## Examples

      iex> Jsonrs.decode("{\\"x\\":[1,2]}")
      {:ok, %{"x" => [1, 2]}}

      iex> Jsonrs.decode("invalid")
      {:error, "expected value at line 1 column 1"}
  """
  @spec decode(iodata, Keyword.t()) :: {:ok, term} | {:error, String.t()}
  def decode(input, opts \\ []) do
    {:ok, decode!(input, opts)}
  rescue
    e -> {:error, error_string(e)}
  end

  @doc """
  Generates JSON corresponding to `input`.

  Similar to `encode/1` except it will raise in case of errors.

  ## Examples

      iex> Jsonrs.encode!(%{"x" => [1,2]})
      "{\\"x\\":[1,2]}"

      iex> Jsonrs.encode!("\\xFF")
      ** (ErlangError) Erlang error: \"Expected to deserialize a UTF-8 stringable term\"
  """
  @spec encode!(term, keyword) :: String.t()
  def encode!(input, opts \\ []) do
    {lean, opts} = Keyword.pop(opts, :lean, false)
    {indent, opts} = Keyword.pop(opts, :pretty, nil)
    {compression, _opts} = Keyword.pop(opts, :compress, :none)
    compression = validate_compression(compression)
    indent = if true == indent, do: 2, else: indent
    case lean do
      true -> input
      false -> Jsonrs.Encoder.encode(input)
    end
    |> nif_encode(indent, compression)
  end

  @doc """
  Parses a JSON value from `input` string.

  Similar to `decode/2` except it will raise in case of errors.

  ## Examples

      iex> Jsonrs.decode!("{\\"x\\":[1,2]}")
      %{"x" => [1, 2]}

      iex> Jsonrs.decode!("invalid")
      ** (ErlangError) Erlang error: "expected value at line 1 column 1"
  """
  @spec decode!(iodata, Keyword.t()) :: term
  def decode!(input, _opts \\ []), do: input |> IO.iodata_to_binary() |> nif_decode()

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

  defp validate_compression(nil), do: {:none, nil}
  defp validate_compression(false), do: {:none, nil}
  defp validate_compression(atom) when is_atom(atom), do: {atom, nil}
  defp validate_compression(other), do: other

  defp error_string(%ErlangError{original: err}), do: error_string(err)
  defp error_string(err) when is_exception(err), do: Exception.message(err)
  defp error_string(err), do: err
end
