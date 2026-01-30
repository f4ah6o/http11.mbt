///|
/// Trailer header parsing errors (RFC 9112 Section 7.1.2)
pub(all) enum TrailerError {
  Empty
  InvalidFormat
  InvalidFieldName
} derive(Show, Eq)

///|
/// Trailer header (RFC 9112 Section 7.1.2)
pub(all) struct Trailer {
  fields : Array[String]
} derive(Show, Eq)

///|
pub fn Trailer::parse(input : String) -> Result[Trailer, TrailerError] {
  let s = trailer_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = trailer_split_string(s, ",")
  let fields : Array[String] = []
  let mut idx = 0
  while idx < parts.length() {
    let name = trailer_trim_string(parts[idx])
    if name.length() == 0 {
      return Err(InvalidFormat)
    }
    if !trailer_is_valid_token(name) {
      return Err(InvalidFieldName)
    }
    fields.push(trailer_to_lower_case(name))
    idx = idx + 1
  }
  if fields.length() == 0 {
    return Err(Empty)
  }
  Ok({ fields, })
}

///|
pub fn Trailer::fields(self : Trailer) -> Array[String] {
  self.fields
}

///|
pub fn Trailer::to_string(self : Trailer) -> String {
  trailer_join_strings(self.fields, ", ")
}

///|
/// Helper functions
///

///|
fn trailer_is_valid_token(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    if !trailer_is_token_char(trailer_char_at(s, idx)) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn trailer_is_token_char(b : Int) -> Bool {
  b == 33 ||
  b == 35 ||
  b == 36 ||
  b == 37 ||
  b == 38 ||
  b == 39 ||
  b == 42 ||
  b == 43 ||
  b == 45 ||
  b == 46 ||
  b == 48 ||
  b == 49 ||
  b == 50 ||
  b == 51 ||
  b == 52 ||
  b == 53 ||
  b == 54 ||
  b == 55 ||
  b == 56 ||
  b == 57 ||
  (b >= 65 && b <= 90) ||
  b == 94 ||
  b == 95 ||
  b == 96 ||
  (b >= 97 && b <= 122) ||
  b == 124 ||
  b == 126
}

///|
fn trailer_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn trailer_to_lower_case(s : String) -> String {
  str_to_lower_case(s)
}

///|
fn trailer_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn trailer_split_string(s : String, sep : String) -> Array[String] {
  str_split_string(s, sep)
}

///|
fn trailer_join_strings(strs : Array[String], sep : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < strs.length() {
    if idx > 0 {
      result = result + sep
    }
    result = result + strs[idx]
    idx = idx + 1
  }
  result
}
