///|
/// Content-Digest header (RFC 9530)
pub(all) struct ContentDigest {
  entries : Array[(String, DigestValue)]
} derive(Eq)

///|
pub fn ContentDigest::parse(
  input : String,
) -> Result[ContentDigest, DigestFieldsError] {
  let s = df_trim(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  match df_parse_dictionary(s, df_parse_byte_sequence) {
    Ok(entries) => Ok({ entries, })
    Err(e) => Err(e)
  }
}

///|
pub fn ContentDigest::entries(
  self : ContentDigest,
) -> Array[(String, DigestValue)] {
  self.entries
}

///|
pub fn ContentDigest::get(
  self : ContentDigest,
  algorithm : String,
) -> DigestValue? {
  let key = df_to_lower_case(algorithm)
  let mut idx = 0
  while idx < self.entries.length() {
    let (alg, val) = self.entries[idx]
    if alg == key {
      return Some(val)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn ContentDigest::to_string(self : ContentDigest) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < self.entries.length() {
    if idx > 0 {
      result = result + ", "
    }
    let (alg, val) = self.entries[idx]
    result = result + alg + "=" + val.to_string()
    idx = idx + 1
  }
  result
}

///|
/// Repr-Digest header (RFC 9530)
pub(all) struct ReprDigest {
  entries : Array[(String, DigestValue)]
} derive(Eq)

///|
pub fn ReprDigest::parse(
  input : String,
) -> Result[ReprDigest, DigestFieldsError] {
  let s = df_trim(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  match df_parse_dictionary(s, df_parse_byte_sequence) {
    Ok(entries) => Ok({ entries, })
    Err(e) => Err(e)
  }
}

///|
pub fn ReprDigest::entries(self : ReprDigest) -> Array[(String, DigestValue)] {
  self.entries
}

///|
pub fn ReprDigest::get(self : ReprDigest, algorithm : String) -> DigestValue? {
  let key = df_to_lower_case(algorithm)
  let mut idx = 0
  while idx < self.entries.length() {
    let (alg, val) = self.entries[idx]
    if alg == key {
      return Some(val)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn ReprDigest::to_string(self : ReprDigest) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < self.entries.length() {
    if idx > 0 {
      result = result + ", "
    }
    let (alg, val) = self.entries[idx]
    result = result + alg + "=" + val.to_string()
    idx = idx + 1
  }
  result
}
