# NIF for Elixir.Jsonrs

Implements `encode` and `decode` and exposes them as `Elixir.Jsonrs.encode!` and `Elixir.Jsonrs.decode!` respectively for use in an Elixir module.

Uses `serde_rustler` and `serde_json` (de)serializers to implement transcoding
