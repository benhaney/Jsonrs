# Jsonrs

A JSON encoding/decoding library for Elixir powered by Rust's Serde though a NIF

## Why?

"Pure Elixir" JSON libraries use a ton of memory when encoding very large JSON strings. Serde and its zero-copy properties allows for much more performant encoding than native Elixir can, and Rust's safety guarentees along with Rustler allow us to ensure that the NIF we produce won't take down the BEAM.

## Examples
```elixir
iex> Jsonrs.encode(%{"x" => [1,2], "y" => 0.5})
{:ok, "{\"x\":[1,2],\"y\":0.5}"}

iex> Jsonrs.decode!("{\"x\":[1,2],\"y\":0.5}")
%{"x" => [1, 2], "y" => 0.5}
```
