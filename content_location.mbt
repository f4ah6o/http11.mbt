///|
/// Content-Location header parsing errors (RFC 9110 Section 8.6)
pub(all) enum ContentLocationError {
  Empty
  InvalidUri
} derive(Show, Eq)

///|
/// Content-Location header (RFC 9110 Section 8.6)
pub(all) struct ContentLocation {
  uri : Uri
} derive(Eq)

///|
pub fn ContentLocation::parse(input : String) -> Result[ContentLocation, ContentLocationError] {
  let s = clo_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  let uri_result = Uri::parse(s)
  match uri_result {
    Ok(uri) => Ok({ uri, })
    Err(_) => Err(InvalidUri)
  }
}

///|
pub fn ContentLocation::uri(self : ContentLocation) -> Uri {
  self.uri
}

///|
pub fn ContentLocation::to_string(self : ContentLocation) -> String {
  self.uri.to_string()
}

///|
/// Helper functions
///

///|
fn clo_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = clo_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = clo_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  clo_string_slice(s, start, end)
}

///|
fn clo_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
}

///|
fn clo_string_slice(s : String, start : Int, end : Int) -> String {
  let mut result = ""
  let mut idx = start
  while idx < end {
    let ch = s[idx]
    result = result + Int::unsafe_to_char(ch.to_int()).to_string()
    idx = idx + 1
  }
  result
}
