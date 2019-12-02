use rustler::{Env, NifResult, Term};
use serde_rustler::{from_term, to_term};

rustler::rustler_export_nifs! {
  "Elixir.Jsonrs",
  [
    ("nif_encode!", 1, encode, rustler::schedule::SchedulerFlags::DirtyCpu),
    ("nif_decode!", 1, decode, rustler::schedule::SchedulerFlags::DirtyCpu),
    ("nif_encode_pretty!", 2, encode_pretty, rustler::schedule::SchedulerFlags::DirtyCpu),
  ],
  None
}

fn encode<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  // Buffer for serde_json's serializer to write to
  let mut buf = Vec::new();
  serde_transcode::transcode(
    serde_rustler::Deserializer::from(args[0]),
    &mut serde_json::Serializer::new(&mut buf)
  ).or(Err(rustler::Error::RaiseAtom("encode_error")))?;
  // Turn the json buffer back into an Elixir binary (string) term
  to_term(env, serde_bytes::Bytes::new(&buf)).map_err(|e| e.into())
}

// Takes a term and an indentation size
fn encode_pretty<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  // Buffer for serde_json's serializer to write to
  let mut buf = Vec::new();
  let indent_size: u32 = from_term(args[1])?;
  let indent = std::iter::repeat(" ").take(indent_size as usize).collect::<String>();
  let formatter = serde_json::ser::PrettyFormatter::with_indent(indent.as_bytes());
  serde_transcode::transcode(
    serde_rustler::Deserializer::from(args[0]),
    &mut serde_json::Serializer::with_formatter(&mut buf, formatter)
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
