///|
/// Content-Encoding header parsing errors (RFC 9110 Section 8.4)
pub(all) enum ContentEncodingError {
  Empty
  InvalidFormat
  InvalidEncoding
} derive(Show, Eq)

///|
/// Content Coding (compression algorithm)
pub(all) enum ContentCoding {
  Gzip
  Deflate
  Compress
  Identity
  Br
  Zstd
  Other(String)
} derive(Show, Eq)

///|
pub fn ContentCoding::to_string(self : ContentCoding) -> String {
  match self {
    Gzip => "gzip"
    Deflate => "deflate"
    Compress => "compress"
    Identity => "identity"
    Br => "br"
    Zstd => "zstd"
    Other(s) => s
  }
}

///|
/// Content-Encoding header (RFC 9110 Section 8.4)
pub(all) struct ContentEncoding {
  encodings : Array[ContentCoding]
} derive(Eq)

///|
pub fn ContentEncoding::parse(
  input : String,
) -> Result[ContentEncoding, ContentEncodingError] {
  let s = ce_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = ce_split_string(s, ",")
  let encodings : Array[ContentCoding] = []
  let mut part_idx = 0
  while part_idx < parts.length() {
    let part = ce_trim_string(parts[part_idx])
    if part.length() > 0 {
      let parse_result = ce_parse_coding(part)
      match parse_result {
        Ok(coding) => encodings.push(coding)
        Err(e) => return Err(e)
      }
    }
    part_idx = part_idx + 1
  }
  if encodings.length() == 0 {
    return Err(Empty)
  }
  Ok({ encodings, })
}

///|
pub fn ContentEncoding::encodings(
  self : ContentEncoding,
) -> Array[ContentCoding] {
  self.encodings
}

///|
pub fn ContentEncoding::has_gzip(self : ContentEncoding) -> Bool {
  ce_contains(self, Gzip)
}

///|
pub fn ContentEncoding::has_deflate(self : ContentEncoding) -> Bool {
  ce_contains(self, Deflate)
}

///|
pub fn ContentEncoding::has_compress(self : ContentEncoding) -> Bool {
  ce_contains(self, Compress)
}

///|
pub fn ContentEncoding::has_identity(self : ContentEncoding) -> Bool {
  ce_contains(self, Identity)
}

///|
pub fn ContentEncoding::has_br(self : ContentEncoding) -> Bool {
  ce_contains(self, Br)
}

///|
pub fn ContentEncoding::has_zstd(self : ContentEncoding) -> Bool {
  ce_contains(self, Zstd)
}

///|
pub fn ContentEncoding::to_string(self : ContentEncoding) -> String {
  let strs = ce_map_encodings(self.encodings, fn(c) { c.to_string() })
  ce_join_strings(strs, ", ")
}

///|
/// Helper functions
///

///|
fn ce_contains(encoding : ContentEncoding, target : ContentCoding) -> Bool {
  let mut idx = 0
  while idx < encoding.encodings.length() {
    let current = encoding.encodings[idx]
    if current == target {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
fn ce_parse_coding(
  token : String,
) -> Result[ContentCoding, ContentEncodingError] {
  let trimmed = ce_trim_string(token)
  if trimmed.length() == 0 {
    return Err(InvalidFormat)
  }
  if !ce_is_valid_token(trimmed) {
    return Err(InvalidEncoding)
  }
  let lower = ce_to_lower_case(trimmed)
  match lower {
    "gzip" => Ok(Gzip)
    "deflate" => Ok(Deflate)
    "compress" => Ok(Compress)
    "identity" => Ok(Identity)
    "br" => Ok(Br)
    "zstd" => Ok(Zstd)
    _ => Ok(Other(lower))
  }
}

///|
fn ce_is_valid_token(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    if !ce_is_token_char(ce_char_at(s, idx)) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn ce_is_token_char(b : Int) -> Bool {
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
  (b >= 48 && b <= 57) || // 0-9
  (b >= 65 && b <= 90) || // A-Z
  b == 94 ||
  b == 95 ||
  b == 96 ||
  (b >= 97 && b <= 122) || // a-z
  b == 124 ||
  b == 126
}

///|
fn ce_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
}

///|
fn ce_to_lower_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = ce_char_at(s, idx)
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
fn ce_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = ce_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = ce_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  ce_string_slice(s, start, end)
}

///|
fn ce_string_slice(s : String, start : Int, end : Int) -> String {
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
fn ce_string_slice_from(s : String, start : Int) -> String {
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
fn ce_split_string(s : String, sep : String) -> Array[String] {
  let result = []
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
      result.push(ce_string_slice(s, start, idx))
      start = idx + sep_len
      idx = start
    } else {
      idx = idx + 1
    }
  }
  result.push(ce_string_slice_from(s, start))
  result
}

///|
fn[T, U] ce_map_encodings(arr : Array[T], f : (T) -> U) -> Array[U] {
  let result : Array[U] = []
  let mut idx = 0
  while idx < arr.length() {
    result.push(f(arr[idx]))
    idx = idx + 1
  }
  result
}

///|
fn ce_join_strings(strs : Array[String], sep : String) -> String {
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
