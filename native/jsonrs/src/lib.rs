use rustler::{Env, Error, Term};

rustler::init!("Elixir.Jsonrs", [encode, decode]);

#[rustler::nif(name = "nif_encode", schedule = "DirtyCpu")]
fn encode(term: Term, indent_size: Option<u32>) -> Result<String, Error> {
  let mut buf = Vec::new();
  let des = serde_rustler::Deserializer::from(term);
  match indent_size {
    None => serde_transcode::transcode(des, &mut serde_json::Serializer::new(&mut buf)),
    Some(inds) => {
      let indent = std::iter::repeat(" ").take(inds as usize).collect::<String>();
      let formatter = serde_json::ser::PrettyFormatter::with_indent(indent.as_bytes());
      serde_transcode::transcode(des, &mut serde_json::Serializer::with_formatter(&mut buf, formatter))
    }
  }.or(Err(Error::RaiseAtom("encode_error")))?;

  unsafe { Ok(String::from_utf8_unchecked(buf)) }
}

#[rustler::nif(name = "nif_decode", schedule = "DirtyCpu")]
fn decode<'a>(env: Env<'a>, string: String) -> Result<Term<'a>, Error> {
  serde_transcode::transcode(
    &mut serde_json::Deserializer::from_slice(string.as_bytes()),
    serde_rustler::Serializer::from(env)
  ).map_err(|e| e.into())
}
