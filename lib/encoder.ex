defprotocol Jsonrs.Encoder do
  @fallback_to_any true
  def encode(data)
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
  def encode(d), do: d |> @for.to_iso8601() |> Jsonrs.Encoder.encode()
end

defimpl Jsonrs.Encoder, for: URI do
  def encode(uri), do: URI.to_string(uri)
end

defimpl Jsonrs.Encoder, for: Any do
  def encode(any), do: any
end
