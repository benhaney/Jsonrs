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
  // Prep Erlang term Deserializer with dynamic stack
  let des = serde_rustler::Deserializer::from(args[0]);
  let des = serde_stacker::Deserializer::new(des);
  // Buffer for Json serializer to write to
  let mut buf = Vec::new();
  // Serialize to JSON sting (in buffer)
  let mut ser = serde_json::Serializer::new(&mut buf);
  // Transcode from Erlang terms to JSON string (in buffer)
  serde_transcode::transcode(des, &mut ser).or(Err(rustler::Error::RaiseAtom("encode_error")))?;
  // Turn the JSON buffer back into an Elixir binary (string) term
  to_term(env, serde_bytes::Bytes::new(&buf)).map_err(|e| e.into())
}

// Takes a term and an indentation size
fn encode_pretty<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  // Prep Erlang term Deserializer with dynamic stack
  let des = serde_rustler::Deserializer::from(args[0]);
  let des = serde_stacker::Deserializer::new(des);
  // Buffer for JSON serializer to write to
  let mut buf = Vec::new();
  // Create pretty-print formatter with indentation size from arg
  let indent_size: u32 = from_term(args[1])?;
  let indent = std::iter::repeat(" ").take(indent_size as usize).collect::<String>();
  let formatter = serde_json::ser::PrettyFormatter::with_indent(indent.as_bytes());
  // Serialize to JSON sting (in buffer)
  let mut ser = serde_json::Serializer::with_formatter(&mut buf, formatter);
  // Transcode from Erlang terms to JSON string (in buffer)
  serde_transcode::transcode(des, &mut ser).or(Err(rustler::Error::RaiseAtom("encode_error")))?;
  // Turn the JSON buffer back into an Elixir binary (string) term
  to_term(env, serde_bytes::Bytes::new(&buf)).map_err(|e| e.into())
}

fn decode<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
  // Prep JSON deserializer with dynamic stack
  let mut des = serde_json::Deserializer::from_slice(from_term(args[0])?);
  des.disable_recursion_limit();
  let des = serde_stacker::Deserializer::new(&mut des);
  // Serializer to Erlang terms
  let ser = serde_rustler::Serializer::from(env);
  // Transcode from Json to Erlang terms
  serde_transcode::transcode(des, ser).map_err(|e| e.into())
}
