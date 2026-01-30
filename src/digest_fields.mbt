///|
/// Digest Fields (RFC 9530)
/// Content-Digest, Repr-Digest, Want-Content-Digest, Want-Repr-Digest
///

///|
/// Digest fields error types
pub(all) enum DigestFieldsError {
  Empty
  InvalidFormat
  InvalidAlgorithm
  InvalidByteSequence
  InvalidBase64
  InvalidPreference
} derive(Show, Eq)

///|
/// Digest value (RFC 9530 section 4)
/// Format: :base64:
pub(all) struct DigestValue {
  bytes : Array[Byte]
} derive(Eq)

///|
pub fn DigestValue::new(bytes : Array[Byte]) -> DigestValue {
  { bytes, }
}

///|
pub fn DigestValue::bytes(self : DigestValue) -> Array[Byte] {
  self.bytes
}

///|
pub fn DigestValue::to_string(self : DigestValue) -> String {
  ":" + df_base64_encode(self.bytes) + ":"
}

///|
/// Digest entry (algorithm + digest value)
pub(all) struct DigestEntry {
  algorithm : String
  value : DigestValue
} derive(Eq)

///|
pub fn DigestEntry::new(algorithm : String, value : DigestValue) -> DigestEntry {
  { algorithm, value }
}

///|
pub fn DigestEntry::algorithm(self : DigestEntry) -> String {
  self.algorithm
}

///|
pub fn DigestEntry::value(self : DigestEntry) -> DigestValue {
  self.value
}

///|
pub fn DigestEntry::to_string(self : DigestEntry) -> String {
  self.algorithm + "=" + self.value.to_string()
}

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

///|
/// Digest preference (algorithm + weight 0-10)
pub(all) struct DigestPreference {
  algorithm : String
  weight : Int
} derive(Eq)

///|
pub fn DigestPreference::new(
  algorithm : String,
  weight : Int,
) -> DigestPreference {
  { algorithm, weight }
}

///|
pub fn DigestPreference::algorithm(self : DigestPreference) -> String {
  self.algorithm
}

///|
pub fn DigestPreference::weight(self : DigestPreference) -> Int {
  self.weight
}

///|
pub fn DigestPreference::to_string(self : DigestPreference) -> String {
  self.algorithm + "=" + df_int_to_string(self.weight)
}

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

///|

///|
/// Parser functions

///|

///|

///|
fn[T] df_parse_dictionary(
  input : String,
  value_parser : (String) -> Result[T, DigestFieldsError],
) -> Result[Array[(String, T)], DigestFieldsError] {
  let s = df_trim(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = df_split_string(s, ",")
  let entries : Array[(String, T)] = []
  let mut idx = 0
  while idx < parts.length() {
    let part = df_trim(parts[idx])
    if part.length() == 0 {
      return Err(InvalidFormat)
    }

    // Split at '='
    let eq_pos = df_find_char(part, 61)
    match eq_pos {
      None => return Err(InvalidFormat)
      Some(pos) => {
        let algorithm = df_trim(df_substring(part, 0, pos))
        let value_str = df_trim(df_substring_from(part, pos + 1))
        if algorithm.length() == 0 {
          return Err(InvalidAlgorithm)
        }
        if !df_is_valid_token(algorithm) {
          return Err(InvalidAlgorithm)
        }
        match value_parser(value_str) {
          Ok(value) => entries.push((df_to_lower_case(algorithm), value))
          Err(e) => return Err(e)
        }
      }
    }
    idx = idx + 1
  }
  if entries.length() == 0 {
    return Err(Empty)
  }
  Ok(entries)
}

///|
fn df_parse_byte_sequence(
  input : String,
) -> Result[DigestValue, DigestFieldsError] {
  // Format: :base64:
  // Find first ':'
  let colon1_pos = df_find_char(input, 58)
  match colon1_pos {
    None => Err(InvalidByteSequence)
    Some(pos) => {
      // Find second ':'
      let rest = df_substring_from(input, pos + 1)
      let colon2_pos = df_find_char(rest, 58)
      match colon2_pos {
        None => Err(InvalidByteSequence)
        Some(cpos) => {
          // Extract base64 between the colons
          let base64 = df_substring(rest, 0, cpos)
          let rest2 = df_substring_from(rest, cpos + 1)
          if !df_trim(rest2).is_empty() {
            return Err(InvalidByteSequence)
          }
          match df_base64_decode(base64) {
            Ok(bytes) => Ok(DigestValue::new(bytes))
            Err(_) => Err(InvalidBase64)
          }
        }
      }
    }
  }
}

///|
fn df_parse_preference(input : String) -> Result[Int, DigestFieldsError] {
  let s = df_trim(input)
  if s.length() == 0 {
    return Err(InvalidPreference)
  }

  // Check if all characters are digits
  let mut idx = 0
  while idx < s.length() {
    let ch = s[idx]
    let ch_code = ch.to_int()
    if ch_code < 48 || ch_code > 57 {
      return Err(InvalidPreference)
    }
    idx = idx + 1
  }
  match df_parse_u8(s) {
    Some(v) => if v > 10 { Err(InvalidPreference) } else { Ok(v) }
    None => Err(InvalidPreference)
  }
}

///|
fn df_is_valid_token(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    let code = s[idx]
    let ch = Int::unsafe_to_char(code.to_int())
    if !df_is_token_char(ch) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn df_is_token_char(ch : Char) -> Bool {
  let code = ch.to_int()
  code == 33 ||
  code == 35 ||
  code == 36 ||
  code == 37 ||
  code == 38 ||
  code == 39 ||
  code == 42 ||
  code == 43 ||
  code == 45 ||
  code == 46 ||
  (code >= 48 && code <= 57) ||
  (code >= 65 && code <= 90) ||
  code == 94 ||
  code == 95 ||
  code == 96 ||
  (code >= 97 && code <= 122) ||
  code == 124 ||
  code == 126
}

///|
/// String helper functions

///|

///|
fn df_trim(s : String) -> String {
  s.trim().to_string()
}

///|
fn df_split_string(s : String, sep : String) -> Array[String] {
  str_split_string(s, sep)
}

///|
fn df_substring(s : String, start : Int, end : Int) -> String {
  (try! s[start:end]).to_string()
}

///|
fn df_substring_from(s : String, start : Int) -> String {
  (try! s[start:s.length()]).to_string()
}

///|
fn df_to_lower_case(s : String) -> String {
  str_to_lower_case(s)
}

///|
fn df_find_char(s : String, target : Int) -> Int? {
  let mut idx = 0
  while idx < s.length() {
    let ch = s[idx]
    if ch.to_int() == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn df_int_to_string(n : Int) -> String {
  if n == 0 {
    return "0"
  }
  if n < 0 {
    "-" + df_int_to_string(-n)
  } else {
    let mut result = ""
    let mut num = n
    while num > 0 {
      result = result + Int::unsafe_to_char(48 + num % 10).to_string()
      num = num / 10
    }
    result
  }
}

///|

///|
/// Base64 encoding/decoding (RFC 4648)
/// Uses same implementation as auth.mbt

///|

///|
fn df_base64_encode(input : Array[Byte]) -> String {
  // Convert ByteArray to Array[Int] for processing
  let len = input.length()
  let mut result = ""
  let mut i = 0

  // Base64 alphabet
  // ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/

  while i < len {
    let b0 = input[i].to_int()
    let b1 = if i + 1 < len { input[i + 1].to_int() } else { 0 }
    let b2 = if i + 2 < len { input[i + 2].to_int() } else { 0 }
    let n = b0 * 65536 + b1 * 256 + b2

    // Encode 6-bit values
    let i0 = n / 262144 // 2^18
    let i1 = n / 4096 % 64 // 2^12
    let i2 = n / 64 % 64
    let i3 = n % 64

    // Map to base64 alphabet
    let c0 = df_base64_char(i0)
    let c1 = df_base64_char(i1)
    let c2 = if i + 1 < len { df_base64_char(i2) } else { "=" }
    let c3 = if i + 2 < len { df_base64_char(i3) } else { "=" }
    result = result + c0 + c1 + c2 + c3
    i = i + 3
  }
  result
}

///|
fn df_base64_char(index : Int) -> String {
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  if index >= 0 && index < 64 {
    (try! alphabet[index:index + 1]).to_string()
  } else {
    "="
  }
}

///|
fn df_base64_decode(input : String) -> Result[Array[Byte], DigestFieldsError] {
  // Remove padding '=' from end
  let s = input.trim().to_string()
  let mut s_len = s.length()

  // Remove trailing '='
  while s_len > 0 && s[s_len - 1] == '=' {
    s_len = s_len - 1
  }
  let result : Array[Byte] = []
  let mut buf = 0
  let mut bits = 0
  let mut idx = 0
  while idx < s_len {
    let ch = s[idx]
    let ch_code = ch.to_int()
    let val = if ch_code >= 65 && ch_code <= 90 {
      // A-Z
      ch_code - 65
    } else if ch_code >= 97 && ch_code <= 122 {
      // a-z
      ch_code - 97 + 26
    } else if ch_code >= 48 && ch_code <= 57 {
      // 0-9
      ch_code - 48 + 52
    } else if ch_code == 43 {
      // +
      62
    } else if ch_code == 47 {
      // /
      63
    } else {
      return Err(InvalidBase64)
    }
    buf = buf * 64 + val
    bits = bits + 6
    if bits >= 8 {
      bits = bits - 8
      let byte = buf / df_pow2(bits)
      result.push(byte.to_byte())
      buf = buf % df_pow2(bits)
    }
    idx = idx + 1
  }
  Ok(result)
}

///|
fn df_pow2(n : Int) -> Int {
  if n == 0 {
    1
  } else if n == 1 {
    2
  } else if n == 2 {
    4
  } else if n == 3 {
    8
  } else if n == 4 {
    16
  } else if n == 5 {
    32
  } else if n == 6 {
    64
  } else if n == 7 {
    128
  } else if n == 8 {
    256
  } else if n == 9 {
    512
  } else if n == 10 {
    1024
  } else {
    1
  }
}

///|
fn df_parse_u8(s : String) -> Int? {
  if s.length() == 0 {
    return None
  }
  let mut result = 0
  let mut idx = 0
  let len = s.length()
  while idx < len {
    let ch = s[idx]
    let ch_code = ch.to_int()
    if ch_code < 48 || ch_code > 57 {
      return None
    }
    result = result * 10 + (ch_code - 48)
    idx = idx + 1
  }
  Some(result)
}
