///|
/// URI parsing errors (RFC 3986)
pub(all) enum UriError {
  Empty
  InvalidPercentEncoding
  InvalidPort
  InvalidCharacter
  InvalidScheme
  InvalidHost
  InvalidUtf8
} derive(Show, Eq)

///|
/// Parsed URI (RFC 3986 Section 3)
///
/// URI structure:
///   foo://example.com:8042/over/there?name=ferret#nose
///   \_/   \______________/\_________/ \_________/ \__/
///    |           |            |            |        |
/// scheme     authority       path        query   fragment
pub(all) struct Uri {
  source : String
  scheme_end : Int?
  authority_start : Int?
  authority_end : Int?
  host_end : Int?
  port : Int?
  path_start : Int
  path_end : Int
  query_start : Int?
  query_end : Int?
  fragment_start : Int?
} derive(Show, Eq)

///|
pub fn Uri::parse(input : String) -> Result[Uri, UriError] {
  let s = uri_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let source = s
  let len = source.length()
  let mut pos = 0

  // Parse scheme (RFC 3986 Section 3.1)
  // scheme = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
  let (scheme_end, pos_after_scheme) = uri_find_scheme_end(source)
  match scheme_end {
    Some(end) => {
      // Validate scheme
      if !uri_is_alpha(uri_string_char_at(source, 0)) {
        return Err(InvalidScheme)
      }
      let mut idx = 1
      while idx < end {
        let ch = uri_string_char_at(source, idx)
        if !uri_is_alnum(ch) && ch != 43 && ch != 45 && ch != 46 { // +, -, .
          return Err(InvalidScheme)
        }
        idx = idx + 1
      }
      pos = pos_after_scheme
    }
    None => ()
  }

  // Parse authority (RFC 3986 Section 3.2)
  let (authority_start, authority_end, host_end, port) = if pos + 1 < len &&
    uri_string_char_at(source, pos) == 47 &&
    uri_string_char_at(source, pos + 1) == 47 { // "//"
    pos = pos + 2
    let auth_start = pos

    // Find authority end
    let auth_end = uri_find_char_from_set(source, pos, 47, 63, 35) // /, ?, #
    let authority = uri_string_slice(source, auth_start, auth_end)
    let auth_result = uri_parse_authority(authority)
    match auth_result {
      Ok((h_end, p)) => {
        pos = auth_end
        (Some(auth_start), Some(auth_end), Some(auth_start + h_end), p)
      }
      Err(e) => return Err(e)
    }
  } else {
    (None, None, None, None)
  }

  // Parse path (RFC 3986 Section 3.3)
  let path_start = pos
  let path_end = uri_find_char_from_set(source, pos, 63, 35, 0) // ?, # (dummy 0)
  pos = path_end

  // Parse query (RFC 3986 Section 3.4)
  let (query_start, query_end) = if pos < len &&
    uri_string_char_at(source, pos) == 63 { // ?
    pos = pos + 1
    let start = pos
    let end_pos = uri_find_char_in(source, pos, 35) // #
    let actual_end = match end_pos {
      Some(e) => e
      None => len
    }
    pos = actual_end
    (Some(start), Some(actual_end))
  } else {
    (None, None)
  }

  // Parse fragment (RFC 3986 Section 3.5)
  let fragment_start = if pos < len && uri_string_char_at(source, pos) == 35 { // #
    Some(pos + 1)
  } else {
    None
  }
  Ok({
    source,
    scheme_end,
    authority_start,
    authority_end,
    host_end,
    port,
    path_start,
    path_end,
    query_start,
    query_end,
    fragment_start,
  })
}

///|
pub fn Uri::scheme(self : Uri) -> String? {
  match self.scheme_end {
    Some(end) => Some(uri_string_slice(self.source, 0, end))
    None => None
  }
}

///|
pub fn Uri::authority(self : Uri) -> String? {
  match (self.authority_start, self.authority_end) {
    (Some(start), Some(end)) => Some(uri_string_slice(self.source, start, end))
    _ => None
  }
}

///|
pub fn Uri::host(self : Uri) -> String? {
  match (self.authority_start, self.host_end) {
    (Some(start), Some(end)) => {
      let auth = uri_string_slice(self.source, start, end)
      // Remove userinfo
      let at_pos = uri_find_char_in(auth, 0, 64) // @
      match at_pos {
        Some(pos) => Some(uri_string_slice_from(auth, pos + 1))
        None => Some(auth)
      }
    }
    _ => None
  }
}

///|
pub fn Uri::port(self : Uri) -> Int? {
  self.port
}

///|
pub fn Uri::path(self : Uri) -> String {
  uri_string_slice(self.source, self.path_start, self.path_end)
}

///|
pub fn Uri::query(self : Uri) -> String? {
  match (self.query_start, self.query_end) {
    (Some(start), Some(end)) => Some(uri_string_slice(self.source, start, end))
    _ => None
  }
}

///|
pub fn Uri::fragment(self : Uri) -> String? {
  match self.fragment_start {
    Some(start) => Some(uri_string_slice_from(self.source, start))
    None => None
  }
}

///|
pub fn Uri::as_str(self : Uri) -> String {
  self.source
}

///|
pub fn Uri::origin_form(self : Uri) -> String {
  let path = self.path()
  let path = if path.length() == 0 { "/" } else { path }
  match self.query() {
    Some(q) => path + "?" + q
    None => path
  }
}

///|
pub fn Uri::is_absolute(self : Uri) -> Bool {
  self.scheme_end != None
}

///|
pub fn Uri::is_relative(self : Uri) -> Bool {
  self.scheme_end == None
}

///|
pub fn Uri::to_string(self : Uri) -> String {
  self.source
}

///|
/// Percent encoding (RFC 3986 Section 2.1)
///

///|
pub fn percent_encode(input : String) -> String {
  let result : Array[Int] = []
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let byte = uri_string_char_at(input, idx)
    if uri_is_unreserved(byte) {
      result.push(byte)
    } else {
      result.push(37) // %
      result.push(uri_to_hex_char(byte >> 4))
      result.push(uri_to_hex_char(byte & 0x0F))
    }
    idx = idx + 1
  }
  uri_bytes_to_string(result)
}

///|
pub fn percent_encode_path(input : String) -> String {
  let result : Array[Int] = []
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let byte = uri_string_char_at(input, idx)
    if uri_is_unreserved(byte) || byte == 47 { // /
      result.push(byte)
    } else {
      result.push(37) // %
      result.push(uri_to_hex_char(byte >> 4))
      result.push(uri_to_hex_char(byte & 0x0F))
    }
    idx = idx + 1
  }
  uri_bytes_to_string(result)
}

///|
pub fn percent_encode_query(input : String) -> String {
  let result : Array[Int] = []
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let byte = uri_string_char_at(input, idx)
    if uri_is_unreserved(byte) || byte == 61 || byte == 38 { // =, &
      result.push(byte)
    } else {
      result.push(37) // %
      result.push(uri_to_hex_char(byte >> 4))
      result.push(uri_to_hex_char(byte & 0x0F))
    }
    idx = idx + 1
  }
  uri_bytes_to_string(result)
}

///|
pub fn percent_decode(input : String) -> Result[String, UriError] {
  match percent_decode_bytes(input) {
    Ok(bytes) => uri_bytes_to_string_result(bytes)
    Err(e) => Err(e)
  }
}

///|
pub fn percent_decode_bytes(input : String) -> Result[Array[Int], UriError] {
  let result : Array[Int] = []
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let byte = uri_string_char_at(input, idx)
    if byte == 37 { // %
      if idx + 2 >= len {
        return Err(InvalidPercentEncoding)
      }
      let high = uri_string_char_at(input, idx + 1)
      let low = uri_string_char_at(input, idx + 2)
      let high_val = uri_from_hex_char(high)
      let low_val = uri_from_hex_char(low)
      match (high_val, low_val) {
        (Some(h), Some(l)) => {
          result.push((h << 4) | l)
          idx = idx + 3
        }
        _ => return Err(InvalidPercentEncoding)
      }
    } else {
      result.push(byte)
      idx = idx + 1
    }
  }
  Ok(result)
}

///|
/// Helper functions
///

///|
fn uri_is_unreserved(byte : Int) -> Bool {
  uri_is_alnum(byte) || byte == 45 || byte == 46 || byte == 95 || byte == 126 // -, ., _, ~
}

///|
fn uri_is_alnum(byte : Int) -> Bool {
  uri_is_alpha(byte) || uri_is_digit(byte)
}

///|
fn uri_is_alpha(byte : Int) -> Bool {
  (byte >= 65 && byte <= 90) || (byte >= 97 && byte <= 122) // A-Z, a-z
}

///|
fn uri_is_digit(byte : Int) -> Bool {
  byte >= 48 && byte <= 57 // 0-9
}

///|
fn uri_to_hex_char(nibble : Int) -> Int {
  if nibble >= 0 && nibble <= 9 {
    48 + nibble // '0' + nibble
  } else {
    65 + nibble - 10 // 'A' + nibble - 10
  }
}

///|
fn uri_from_hex_char(byte : Int) -> Int? {
  if byte >= 48 && byte <= 57 { // 0-9
    Some(byte - 48)
  } else if byte >= 65 && byte <= 70 { // A-F
    Some(byte - 65 + 10)
  } else if byte >= 97 && byte <= 102 { // a-f
    Some(byte - 97 + 10)
  } else {
    None
  }
}

///|
fn uri_find_scheme_end(s : String) -> (Int?, Int) {
  let mut idx = 0
  let len = s.length()
  while idx < len {
    let ch = uri_string_char_at(s, idx)
    if ch == 58 { // :
      if idx > 0 {
        return (Some(idx), idx + 1)
      } else {
        return (None, 0)
      }
    }
    // Check if char is valid for scheme
    if !uri_is_alnum(ch) && ch != 43 && ch != 45 && ch != 46 { // +, -, .
      return (None, 0)
    }
    idx = idx + 1
  }
  (None, 0)
}

///|
fn uri_parse_authority(authority : String) -> Result[(Int, Int?), UriError] {
  if authority.length() == 0 {
    return Ok((0, None))
  }

  // Remove userinfo
  let at_pos = uri_find_char_in(authority, 0, 64) // @
  let host_part = match at_pos {
    Some(pos) => uri_string_slice_from(authority, pos + 1)
    None => authority
  }

  // IPv6 address
  if uri_string_char_at(host_part, 0) == 91 { // [
    let bracket_end = uri_find_char_in(host_part, 0, 93) // ]
    match bracket_end {
      Some(end) => {
        let after_bracket = uri_string_slice_from(host_part, end + 1)
        if after_bracket.length() == 0 {
          Ok((authority.length(), None))
        } else if uri_string_char_at(after_bracket, 0) == 58 { // :
          let port_str = uri_string_slice_from(after_bracket, 1)
          match uri_parse_port(port_str) {
            Some(p) =>
              Ok((authority.length() - after_bracket.length(), Some(p)))
            None => Err(InvalidPort)
          }
        } else {
          Err(InvalidHost)
        }
      }
      None => Err(InvalidHost)
    }
  } else {
    // Regular host:port
    let colon_pos = uri_find_char_in(host_part, 0, 58) // :
    match colon_pos {
      Some(pos) => {
        let port_str = uri_string_slice_from(host_part, pos + 1)
        if port_str.length() > 0 {
          match uri_parse_port(port_str) {
            Some(p) => {
              let host_end = match at_pos {
                Some(at) => at + 1 + pos
                None => pos
              }
              Ok((host_end, Some(p)))
            }
            None => Err(InvalidPort)
          }
        } else {
          Ok((authority.length(), None))
        }
      }
      None => Ok((authority.length(), None))
    }
  }
}

///|
fn uri_parse_port(port_str : String) -> Int? {
  let mut result = 0
  let mut idx = 0
  let len = port_str.length()
  if len == 0 {
    return None
  }
  while idx < len {
    let ch = uri_string_char_at(port_str, idx)
    if !uri_is_digit(ch) {
      return None
    }
    result = result * 10 + (ch - 48)
    if result > 65535 {
      return None
    }
    idx = idx + 1
  }
  Some(result)
}

///|
fn uri_find_char_from_set(
  s : String,
  start : Int,
  c1 : Int,
  c2 : Int,
  c3 : Int,
) -> Int {
  let mut idx = start
  let len = s.length()
  while idx < len {
    let ch = uri_string_char_at(s, idx)
    if ch == c1 || ch == c2 || ch == c3 {
      return idx
    }
    idx = idx + 1
  }
  len
}

///|
fn uri_find_char_in(s : String, start : Int, target : Int) -> Int? {
  let mut idx = start
  let len = s.length()
  while idx < len {
    if uri_string_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn uri_string_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn uri_string_slice(s : String, start : Int, end : Int) -> String {
  str_string_slice(s, start, end)
}

///|
fn uri_string_slice_from(s : String, start : Int) -> String {
  str_string_slice_from(s, start)
}

///|
fn uri_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn uri_bytes_to_string(bytes : Array[Int]) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < bytes.length() {
    let byte = bytes[idx]
    result = result + Int::unsafe_to_char(byte).to_string()
    idx = idx + 1
  }
  result
}

///|
fn uri_bytes_to_string_result(bytes : Array[Int]) -> Result[String, UriError] {
  Ok(uri_bytes_to_string(bytes))
}
