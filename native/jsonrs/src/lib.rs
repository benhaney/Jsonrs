use rustler::{Env, NifResult, Term};
use serde_rustler::{from_term, to_term};

rustler::rustler_export_nifs! {
  "Elixir.Jsonrs",
  [
    ("encode!", 1, encode, rustler::schedule::SchedulerFlags::DirtyCpu),
    ("decode!", 1, decode, rustler::schedule::SchedulerFlags::DirtyCpu)
  ],
  None
}

fn encode<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  // Buffer for serde_json's serializer to write to
  let mut buf = Vec::new();
  // Deserialize from Elixir term via serde_rustler and serialize to json bytes via serde_json
  serde_transcode::transcode(
    serde_rustler::Deserializer::from(args[0]),
    &mut serde_json::Serializer::new(&mut buf)
  ).or(Err(rustler::Error::RaiseAtom("encode_error")))?;
  // Turn the json buffer back into an Elixir binary (string) term
  to_term(env, serde_bytes::Bytes::new(&buf)).map_err(|e| e.into())
}

fn decode<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  // Transcode the Json bytes from an Elixir string term right back into a deserialized Elixir term
  serde_transcode::transcode(
    &mut serde_json::Deserializer::from_slice(from_term(args[0])?),
    serde_rustler::Serializer::from(env)
  ).map_err(|e| e.into())
}
