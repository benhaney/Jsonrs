use rustler::NifUnitEnum;
use flate2::Compression;
use flate2::write::{DeflateEncoder, GzEncoder, ZlibEncoder};
use std::io::{BufWriter, Write, Error};

#[derive(NifUnitEnum)]
pub enum Algs {
  None,
  Deflate,
  Gzip,
  Zlib,
}

pub trait BufWrapper: Write {
  fn get_buf(&mut self) -> Result<Vec<u8>, Error>;
}

impl BufWrapper for Vec<u8> {
  fn get_buf(&mut self) -> Result<Vec<u8>, Error> { Ok(self.to_vec()) }
}

macro_rules! impl_BufWrapper {
  (for $($t:ty),+) => {
    $(impl BufWrapper for $t {
      fn get_buf(&mut self) -> Result<Vec<u8>, Error> {
        self.flush()?;
        self.get_mut().try_finish()?;
        Ok(self.get_ref().get_ref().to_vec())
      }
    })*
  }
}

impl_BufWrapper!(for
  BufWriter<DeflateEncoder<Vec<u8>>>,
  BufWriter<GzEncoder<Vec<u8>>>,
  BufWriter<ZlibEncoder<Vec<u8>>>
);

pub fn get_writer(opts: Option<(Algs, Option<u32>)>) -> Box<dyn BufWrapper> {
  let comp_lvl = match opts {
    Some((_, Some(lvl))) => Compression::new(lvl),
    _ => Compression::default(),
  };
  match opts {
    Some((Algs::Deflate, _)) => Box::new(BufWriter::with_capacity(10_240, DeflateEncoder::new(Vec::new(), comp_lvl))),
    Some((Algs::Gzip, _)) => Box::new(BufWriter::with_capacity(10_240, GzEncoder::new(Vec::new(), comp_lvl))),
    Some((Algs::Zlib, _)) => Box::new(BufWriter::with_capacity(10_240, ZlibEncoder::new(Vec::new(), comp_lvl))),
    _ => Box::new(Vec::<u8>::new()),
  }
}
