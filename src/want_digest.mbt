///|
/// Want-Content-Digest header (RFC 9530)
pub(all) struct WantContentDigest {
  preferences : Array[DigestPreference]
} derive(Eq)

///|
pub fn WantContentDigest::parse(
  input : String,
) -> Result[WantContentDigest, DigestFieldsError] {
  let s = df_trim(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  match df_parse_dictionary(s, df_parse_preference) {
    Ok(entries) => {
      let preferences = []
      let mut idx = 0
      while idx < entries.length() {
        let (algorithm, weight) = entries[idx]
        preferences.push(DigestPreference::new(algorithm, weight))
        idx = idx + 1
      }
      Ok({ preferences, })
    }
    Err(e) => Err(e)
  }
}

///|
pub fn WantContentDigest::preferences(
  self : WantContentDigest,
) -> Array[DigestPreference] {
  self.preferences
}

///|
pub fn WantContentDigest::get(
  self : WantContentDigest,
  algorithm : String,
) -> Int? {
  let key = df_to_lower_case(algorithm)
  let mut idx = 0
  while idx < self.preferences.length() {
    let pref = self.preferences[idx]
    if pref.algorithm == key {
      return Some(pref.weight)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn WantContentDigest::to_string(self : WantContentDigest) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < self.preferences.length() {
    if idx > 0 {
      result = result + ", "
    }
    result = result + self.preferences[idx].to_string()
    idx = idx + 1
  }
  result
}

///|
/// Want-Repr-Digest header (RFC 9530)
pub(all) struct WantReprDigest {
  preferences : Array[DigestPreference]
} derive(Eq)

///|
pub fn WantReprDigest::parse(
  input : String,
) -> Result[WantReprDigest, DigestFieldsError] {
  let s = df_trim(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  match df_parse_dictionary(s, df_parse_preference) {
    Ok(entries) => {
      let preferences = []
      let mut idx = 0
      while idx < entries.length() {
        let (algorithm, weight) = entries[idx]
        preferences.push(DigestPreference::new(algorithm, weight))
        idx = idx + 1
      }
      Ok({ preferences, })
    }
    Err(e) => Err(e)
  }
}

///|
pub fn WantReprDigest::preferences(
  self : WantReprDigest,
) -> Array[DigestPreference] {
  self.preferences
}

///|
pub fn WantReprDigest::get(self : WantReprDigest, algorithm : String) -> Int? {
  let key = df_to_lower_case(algorithm)
  let mut idx = 0
  while idx < self.preferences.length() {
    let pref = self.preferences[idx]
    if pref.algorithm == key {
      return Some(pref.weight)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn WantReprDigest::to_string(self : WantReprDigest) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < self.preferences.length() {
    if idx > 0 {
      result = result + ", "
    }
    result = result + self.preferences[idx].to_string()
    idx = idx + 1
  }
  result
}
