defprotocol Jsonrs.Encoder do
  @moduledoc """
  Protocol controlling how a value is encoded to JSON.

  By default, structs are encoded as maps without the `:__struct__` key. If this
  is sufficient for you use, you don't need to implement this protocol.

  When implementing an encoding function, the goal is to turn your value into
  something already capable of being encoded.

  ## Example

  An implementation of this protocol for `Decimal` might look something like

      defimpl Jsonrs.Encoder, for: Decimal do
        def encode(value) do
          Decimal.to_string(value)
        end
      end

  Which will cause the Decimal to be encoded as its string representation

  """

  @fallback_to_any true

  @doc """
  Converts `value` to a JSON-encodable type.
  """
  def encode(value)
end

defimpl Jsonrs.Encoder, for: Map do
  def encode(map), do: :maps.map(fn _, v -> Jsonrs.Encoder.encode(v) end, map)
end

defimpl Jsonrs.Encoder, for: List do
  def encode(list), do: Enum.map(list, &Jsonrs.Encoder.encode/1)
end

defimpl Jsonrs.Encoder, for: Tuple do
  def encode(tuple) do
    tuple |> Tuple.to_list() |> Jsonrs.Encoder.encode()
  end
end

defimpl Jsonrs.Encoder, for: [Date, Time, NaiveDateTime, DateTime] do
  def encode(d), do: d |> @for.to_iso8601()
end

defimpl Jsonrs.Encoder, for: URI do
  def encode(uri), do: URI.to_string(uri)
end

defimpl Jsonrs.Encoder, for: Any do
  def encode(s) when is_struct(s), do: s |> Map.from_struct() |> Jsonrs.Encoder.encode()
  def encode(any), do: any
end
