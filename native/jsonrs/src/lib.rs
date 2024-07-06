use rustler::{serde::{Deserializer, Serializer}, Env, Error, Term};
mod compression;

rustler::init!("Elixir.Jsonrs", [encode, decode]);

#[rustler::nif(name = "nif_encode", schedule = "DirtyCpu")]
fn encode(term: Term, indent_size: Option<u32>, comp_opts: Option<(compression::Algs, Option<u32>)>) -> Result<String, Error> {
  let mut buf = compression::get_writer(comp_opts);
  let des = Deserializer::from(term);
  match indent_size {
    None => serde_transcode::transcode(des, &mut serde_json::Serializer::new(&mut buf)),
    Some(inds) => {
      let indent = std::iter::repeat(" ").take(inds as usize).collect::<String>();
      let formatter = serde_json::ser::PrettyFormatter::with_indent(indent.as_bytes());
      serde_transcode::transcode(des, &mut serde_json::Serializer::with_formatter(&mut buf, formatter))
    }
  }.map_err(|e| Error::RaiseTerm(Box::new(format!("{}", e))))?;

  let output = buf.get_buf().map_err(|e| Error::RaiseTerm(Box::new(format!("{}", e))))?;

  unsafe { Ok(String::from_utf8_unchecked(output)) }
}

#[rustler::nif(name = "nif_decode", schedule = "DirtyCpu")]
fn decode<'a>(env: Env<'a>, string: String) -> Result<Term<'a>, Error> {
  serde_transcode::transcode(
    &mut serde_json::Deserializer::from_slice(string.as_bytes()),
    Serializer::from(env)
  ).map_err(|e| e.into())
}
