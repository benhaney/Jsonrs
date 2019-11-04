# Jsonrs

A safe NIF-based JSON library for Elixir powered by Rust's Serde. [API Documentation](https://hexdocs.pm/jsonrs/Jsonrs.html).

## Installation

Add Jsonrs as a dependency in your `mix.exs` file.

```elixir
def deps do
  [{:jsonrs, "~> 0.1"}]
end
```

## Summary

Jsonrs is much faster than other JSON libraries for Elixir, including other NIFs like jiffy.

It uses much less memory than other JSON libraries when operating in a mode with comparable features.

It has an API typical of Elixir JSON libraries. `decode/1` `encode/2` and `encode_to_iodata/2` are available along with their raising `!` counterparts, and structs can implement the `Jsonrs.Encoder` protocol to specify custom encoding.

Multiple operating modes allow you to turn off features you don't need for extra performance. In the default 2-pass mode, Jsonrs works like Jason and Poison and honors custom encoding of structs. In the opt-in 1-pass (_lean_) mode, Jsonrs will ignore custom encoding impls and operate more like jiffy.

## Encoder Design

Jsonrs is a 2-pass encoder by default.

The first pass involves mapping the input object according to any custom encodings implemented for types in the input. This is done in Elixir.

The second pass performs the actual encoding of the input to a JSON string. This is done in the Rust NIF.

If custom encoding defintions are not required, the first pass can be disabled entirely by passing `lean: true` in the encode opts. When operating in this mode, structs will always be encoded as if they were maps regardless of custom encoder implementations.

## Performance

Jsonrs has different performance characteristics in different modes.
In the default 2-pass mode, Jsonrs is comparable feature-wise to Jason or Poison and should always be much faster (~5-10x) and consume less memory (~3-30x) than either of them.
In lean mode, Jsonrs is comparable feature-wise to jiffy and should always be faster (~3x) and use less memory (~100x+) than it.

For example, here is a benchmark of Jsonrs's speed and memory consumption compared to other popular JSON libraries when encoding the 8MB [issue-90.json](https://github.com/devinus/poison/blob/a4208a6252f4e58fbcc8d9fd2f4f64c99e974cc8/bench/data/issue-90.json) from the Poison benchmark data.
![Speed comparison of JSON libraries](https://raw.githubusercontent.com/benhaney/Jsonrs/bd8a008bcee93a0418646e4a8b32b8e26492fe97/bench-speed.png)
![Memory comparison of JSON libraries](https://raw.githubusercontent.com/benhaney/Jsonrs/bd8a008bcee93a0418646e4a8b32b8e26492fe97/bench-memory.png)

It is easy to see that Jsonrs dramatically outperforms Poison and Jason, while Jsonrs-lean similarly outperforms jiffy.

## Quick Start

`Jsonrs.decode/1` takes a JSON string and turns it into an Elixir term.

`Jsonrs.encode/2` takes an Elixir term and a keyword list of options and turns the input term into a JSON string with behavior defined by the options. Valid options are:
* `lean`: disables the first encoder pass (default `false`)
* `pretty`: turns on pretty printing when `true` or a non-negative-integer specifying indentation size (default `false`)

## Examples

### Basic usage
```elixir
iex> Jsonrs.encode!(%{"x" => [1,2], "y" => 0.5}) |> IO.puts()
{"x":[1,2],"y":0.5}

iex> Jsonrs.decode!("{\"x\":[1,2],\"y\":0.5}")
%{"x" => [1, 2], "y" => 0.5}

iex> Jsonrs.encode!(%{"x" => false, "y" => []}, pretty: true) |> IO.puts()
{
  "x": false,
  "y": []
}
```

### Defining a custom encoder

```elixir
defimpl Jsonrs.Encoder, for: [MapSet, Range, Stream] do
  def encode(struct), do: Enum.to_list(struct)
end
```

## Ingredients

Jsonrs is a scoop of [Serde_rustler](https://github.com/sunny-g/serde_rustler) and a scoop of [Serde_json](https://github.com/serde-rs/json) on a bed of [Rustler](https://github.com/rusterlium/rustler) with a [Jason](https://github.com/michalmuskala/jason)-inspired glaze.
