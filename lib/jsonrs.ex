defmodule Jsonrs do
  @moduledoc """
  A JSON library powered by Rust's Serde through a NIF
  """
  use Rustler, otp_app: :jsonrs, crate: "jsonrs"

  @spec nif_encode!(term, integer) :: String.t()
  defp nif_encode!(_input, _indent), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_decode!(term) :: String.t()
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
  @spec decode(String.t()) :: {:ok, term} | {:error, String.t()}
  def decode(input) do
    {:ok, decode!(input)}
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
    indent = case Keyword.pop(opts, :pretty, -1) do
      {true, _} -> 2
      {x, _} -> x
    end
    case lean do
      true -> nif_encode!(input, indent)
      false -> nif_encode!(Jsonrs.Encoder.encode(input), indent)
    end
  end

  @doc """
  Parses a JSON value from `input` string.

  Similar to `decode/1` except it will raise in case of errors.

  ## Examples

    iex> Jsonrs.decode!("{\\"x\\":[1,2]}")
    %{"x" => [1, 2]}

    iex> Jsonrs.decode!("invalid")
    ** (ErlangError) Erlang error: "expected value at line 1 column 1"
  """
  @spec decode!(String.t()) :: term
  def decode!(input), do: nif_decode!(input)

  @doc """
  Identical to `encode\1`. Exists to implement Phoenix interface and encodes to a single normal string.
  """
  @spec encode_to_iodata(term, keyword) :: {:ok, String.t()} | {:error, :encode_error}
  def encode_to_iodata(input, opts \\ []), do: encode(input, opts)

  @doc """
  Identical to `encode!\1`. Exists to implement Phoenix interface and encodes to a single normal string.
  """
  @spec encode_to_iodata!(term, keyword) :: String.t()
  def encode_to_iodata!(input, opts \\ []), do: encode!(input, opts)
end
