///|
/// Vary header parsing errors (RFC 9110 Section 12.5.5)
pub(all) enum VaryError {
  Empty
  InvalidFormat
  InvalidFieldName
} derive(Show, Eq)

///|
/// Vary header (RFC 9110 Section 12.5.5)
pub(all) struct Vary {
  any : Bool
  fields : Array[String]
} derive(Show, Eq)

///|
pub fn Vary::parse(input : String) -> Result[Vary, VaryError] {
  let s = vary_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  if s == "*" {
    return Ok({ any: true, fields: [] })
  }
  let parts = vary_split_string(s, ",")
  let fields : Array[String] = []
  let mut idx = 0
  while idx < parts.length() {
    let name = vary_trim_string(parts[idx])
    if name.length() == 0 {
      return Err(InvalidFormat)
    }
    if !vary_is_valid_token(name) {
      return Err(InvalidFieldName)
    }
    fields.push(vary_to_lower_case(name))
    idx = idx + 1
  }
  if fields.length() == 0 {
    return Err(Empty)
  }
  Ok({ any: false, fields })
}

///|
pub fn Vary::is_any(self : Vary) -> Bool {
  self.any
}

///|
pub fn Vary::fields(self : Vary) -> Array[String] {
  self.fields
}

///|
pub fn Vary::to_string(self : Vary) -> String {
  if self.any {
    "*"
  } else {
    vary_join_strings(self.fields, ", ")
  }
}

///|
/// Helper functions
///

///|
fn vary_is_valid_token(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    if !vary_is_token_char(vary_char_at(s, idx)) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn vary_is_token_char(b : Int) -> Bool {
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
fn vary_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
}

///|
fn vary_to_lower_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = vary_char_at(s, idx)
    if ch >= 65 && ch <= 90 { // A-Z
      result = result + Int::unsafe_to_char(ch + 32).to_string()
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
    }
    idx = idx + 1
  }
  result
}

///|
fn vary_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = vary_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = vary_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  vary_string_slice(s, start, end)
}

///|
fn vary_split_string(s : String, sep : String) -> Array[String] {
  let result : Array[String] = []
  let mut start = 0
  let sep_len = sep.length()
  let mut idx = 0
  while idx <= s.length() - sep_len {
    let mut is_match = true
    let mut j = 0
    while j < sep_len {
      if s[idx + j] != sep[j] {
        is_match = false
        break
      }
      j = j + 1
    }
    if is_match {
      result.push(vary_string_slice(s, start, idx))
      start = idx + sep_len
      idx = start
    } else {
      idx = idx + 1
    }
  }
  result.push(vary_string_slice_from(s, start))
  result
}

///|
fn vary_string_slice(s : String, start : Int, end : Int) -> String {
  let mut result = ""
  let mut idx = start
  while idx < end {
    let ch = s[idx]
    result = result + Int::unsafe_to_char(ch.to_int()).to_string()
    idx = idx + 1
  }
  result
}

///|
fn vary_string_slice_from(s : String, start : Int) -> String {
  let mut result = ""
  let mut idx = start
  let len = s.length()
  while idx < len {
    let ch = s[idx]
    result = result + Int::unsafe_to_char(ch.to_int()).to_string()
    idx = idx + 1
  }
  result
}

///|
fn vary_join_strings(strs : Array[String], sep : String) -> String {
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
