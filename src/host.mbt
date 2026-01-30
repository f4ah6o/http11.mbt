///|
/// Host header parsing errors (RFC 9110 Section 7.2)
pub(all) enum HostError {
  Empty
  InvalidFormat
  InvalidHost
  InvalidPort
} derive(Show, Eq)

///|
/// Host header (RFC 9110 Section 7.2)
pub(all) struct Host {
  host : String
  port : Int?
} derive(Show, Eq)

///|
pub fn Host::parse(input : String) -> Result[Host, HostError] {
  let s = host_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  // Check for whitespace
  if host_has_whitespace(s) {
    return Err(InvalidFormat)
  }

  // IPv6 address
  if host_string_starts_with(s, "[") {
    return host_parse_ipv6(s)
  }
  let split_result = host_split_host_port(s)
  match split_result {
    Err(e) => return Err(e)
    Ok((host_part, port)) => {
      if host_part.length() == 0 || host_contains(host_part, 64) { // @
        return Err(InvalidHost)
      }

      // Check if it's a valid IPv4 address or reg-name
      if !host_is_valid_ipv4_or_reg_name(host_part) {
        return Err(InvalidHost)
      }
      Ok({ host: host_part, port })
    }
  }
}

///|
pub fn Host::host(self : Host) -> String {
  self.host
}

///|
pub fn Host::port(self : Host) -> Int? {
  self.port
}

///|
pub fn Host::is_ipv6(self : Host) -> Bool {
  host_string_starts_with(self.host, "[")
}

///|
pub fn Host::to_string(self : Host) -> String {
  match self.port {
    Some(p) => self.host + ":" + p.to_string()
    None => self.host
  }
}

///|
/// Helper functions
///

///|
fn host_parse_ipv6(input : String) -> Result[Host, HostError] {
  let end = host_find_char_in(input, 0, 93) // ]
  match end {
    None => Err(InvalidHost)
    Some(e) => {
      let host_inner = host_string_slice(input, 1, e)
      let rest = host_string_slice_from(input, e + 1)
      let port : Int? = if rest.length() == 0 {
        None
      } else if host_string_starts_with(rest, ":") {
        let port_str = host_string_slice_from(rest, 1)
        match host_parse_port(port_str) {
          Some(p) => Some(p)
          None => return Err(InvalidPort)
        }
      } else {
        return Err(InvalidHost)
      }
      if host_inner.length() == 0 {
        return Err(InvalidHost)
      }

      // Basic IPv6 validation (just check for hex digits and colons)
      if !host_is_valid_ipv6_content(host_inner) {
        return Err(InvalidHost)
      }
      Ok({ host: host_string_slice(input, 0, e + 1), port })
    }
  }
}

///|
fn host_split_host_port(input : String) -> Result[(String, Int?), HostError] {
  let colon_pos = host_find_last_char_in(input, 58) // :
  match colon_pos {
    Some(pos) => {
      let host_part = host_string_slice(input, 0, pos)
      let port_str = host_string_slice_from(input, pos + 1)

      // Check if host part contains multiple colons (IPv6 without brackets)
      if host_contains(host_part, 58) {
        return Err(InvalidHost)
      }
      if port_str.length() == 0 {
        return Err(InvalidPort)
      }
      match host_parse_port(port_str) {
        Some(p) => Ok((host_part, Some(p)))
        None => Err(InvalidPort)
      }
    }
    None => Ok((input, None))
  }
}

///|
fn host_parse_port(input : String) -> Int? {
  if input.length() == 0 {
    return None
  }
  let mut result = 0
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let ch = host_char_at(input, idx)
    if !host_is_digit(ch) {
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
fn host_is_valid_ipv4_or_reg_name(input : String) -> Bool {
  // Try to parse as IPv4 first
  if host_is_valid_ipv4(input) {
    return true
  }

  // Check if it's a valid reg-name
  host_is_valid_reg_name(input)
}

///|
fn host_is_valid_ipv4(input : String) -> Bool {
  let parts = host_split_string(input, ".")
  if parts.length() != 4 {
    return false
  }
  let mut idx = 0
  while idx < parts.length() {
    let part = parts[idx]
    if !host_is_valid_ipv4_part(part) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn host_is_valid_ipv4_part(input : String) -> Bool {
  if input.length() == 0 || input.length() > 3 {
    return false
  }
  let mut idx = 0
  while idx < input.length() {
    let ch = host_char_at(input, idx)
    if !host_is_digit(ch) {
      return false
    }
    idx = idx + 1
  }

  // Check numeric value
  let value = host_parse_int(input)
  match value {
    Some(v) => v >= 0 && v <= 255
    None => false
  }
}

///|
fn host_parse_int(input : String) -> Int? {
  let mut result = 0
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let ch = host_char_at(input, idx)
    if !host_is_digit(ch) {
      return None
    }
    result = result * 10 + (ch - 48)
    idx = idx + 1
  }
  Some(result)
}

///|
fn host_is_valid_reg_name(input : String) -> Bool {
  if input.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < input.length() {
    let b = host_char_at(input, idx)
    if host_is_unreserved(b) || host_is_sub_delim(b) {
      idx = idx + 1
      continue
    }
    if b == 37 { // %
      if idx + 2 >= input.length() {
        return false
      }
      let h1 = host_char_at(input, idx + 1)
      let h2 = host_char_at(input, idx + 2)
      if !host_is_hexdig(h1) || !host_is_hexdig(h2) {
        return false
      }
      idx = idx + 3
      continue
    }
    return false
  }
  true
}

///|
fn host_is_valid_ipv6_content(input : String) -> Bool {
  if input.length() == 0 {
    return false
  }

  // Check for IPvFuture (v or V prefix)
  let first = host_char_at(input, 0)
  if first == 118 || first == 86 { // v or V
    return host_is_valid_ipvfuture(input)
  }

  // Basic validation: hex digits, colons, double colons
  let mut idx = 0
  while idx < input.length() {
    let ch = host_char_at(input, idx)
    if !host_is_hexdig(ch) && ch != 58 { // :
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn host_is_valid_ipvfuture(input : String) -> Bool {
  if input.length() < 3 {
    return false
  }
  let first = host_char_at(input, 0)
  if first != 118 && first != 86 { // v or V
    return false
  }
  let mut idx = 1
  let mut hex_len = 0
  while idx < input.length() && host_is_hexdig(host_char_at(input, idx)) {
    hex_len = hex_len + 1
    idx = idx + 1
  }
  if hex_len == 0 || idx >= input.length() || host_char_at(input, idx) != 46 { // .
    return false
  }
  idx = idx + 1
  if idx >= input.length() {
    return false
  }
  while idx < input.length() {
    let b = host_char_at(input, idx)
    if !host_is_ipvfuture_char(b) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn host_is_ipvfuture_char(b : Int) -> Bool {
  host_is_unreserved(b) || host_is_sub_delim(b) || b == 58 // :
}

///|
fn host_is_unreserved(b : Int) -> Bool {
  host_is_alnum(b) || b == 45 || b == 46 || b == 95 || b == 126 // -, ., _, ~
}

///|
fn host_is_alnum(b : Int) -> Bool {
  host_is_alpha(b) || host_is_digit(b)
}

///|
fn host_is_alpha(b : Int) -> Bool {
  (b >= 65 && b <= 90) || (b >= 97 && b <= 122) // A-Z, a-z
}

///|
fn host_is_digit(b : Int) -> Bool {
  b >= 48 && b <= 57 // 0-9
}

///|
fn host_is_hexdig(b : Int) -> Bool {
  host_is_digit(b) || (b >= 65 && b <= 70) || (b >= 97 && b <= 102) // A-F, a-f
}

///|
fn host_is_sub_delim(b : Int) -> Bool {
  b == 33 ||
  b == 36 ||
  b == 38 ||
  b == 39 ||
  b == 40 ||
  b == 41 ||
  b == 42 ||
  b == 43 ||
  b == 44 ||
  b == 59 ||
  b == 61 // !, $, &, ', (, ), *, +, ,, ;, =
}

///|
fn host_has_whitespace(s : String) -> Bool {
  let mut idx = 0
  while idx < s.length() {
    let ch = host_char_at(s, idx)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 { // space, tab, LF, CR
      return true
    }
    idx = idx + 1
  }
  false
}

///|
fn host_string_starts_with(s : String, prefix : String) -> Bool {
  if prefix.length() > s.length() {
    return false
  }
  let mut idx = 0
  while idx < prefix.length() {
    if s[idx] != prefix[idx] {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn host_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn host_find_char_in(s : String, start : Int, target : Int) -> Int? {
  let mut idx = start
  while idx < s.length() {
    if host_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn host_find_last_char_in(s : String, target : Int) -> Int? {
  let mut idx = s.length() - 1
  while idx >= 0 {
    if host_char_at(s, idx) == target {
      return Some(idx)
    }
    if idx == 0 {
      break
    }
    idx = idx - 1
  }
  None
}

///|
fn host_contains(s : String, target : Int) -> Bool {
  match host_find_char_in(s, 0, target) {
    Some(_) => true
    None => false
  }
}

///|
fn host_string_slice(s : String, start : Int, end : Int) -> String {
  str_string_slice(s, start, end)
}

///|
fn host_string_slice_from(s : String, start : Int) -> String {
  str_string_slice_from(s, start)
}

///|
fn host_split_string(s : String, sep : String) -> Array[String] {
  str_split_string(s, sep)
}

///|
fn host_trim_string(s : String) -> String {
  str_trim_string(s)
}
