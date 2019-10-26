defmodule Jsonrs do
  @moduledoc """
  A JSON library powered by Rust's Serde through a NIF
  """
  use Rustler, otp_app: :jsonrs, crate: "jsonrs"

  @doc """
  Generates JSON corresponding to `input`.

  ## Examples

    iex> Jsonrs.encode(%{"x" => [1,2]})
    {:ok, "{\\"x\\":[1,2]}"}

    iex> Jsonrs.encode("\\xFF")
    {:error, :encode_error}
  """
  @spec encode(term) :: {:ok, String.t()} | {:error, :encode_error}
  def encode(input) do
    {:ok, encode!(input)}
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
  @spec encode!(term) :: String.t()
  def encode!(_input), do: :erlang.nif_error(:nif_not_loaded)

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
  def decode!(_input), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Identical to `encode\1`. Exists to implement Phoenix interface and encodes to a single normal string.
  """
  @spec encode_to_iodata(term) :: {:ok, String.t()} | {:error, :encode_error}
  def encode_to_iodata(input), do: encode(input)

  @doc """
  Identical to `encode!\1`. Exists to implement Phoenix interface and encodes to a single normal string.
  """
  @spec encode_to_iodata!(term) :: String.t()
  def encode_to_iodata!(input), do: encode!(input)
end
