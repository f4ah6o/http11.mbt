///|
/// Upgrade header parsing errors (RFC 9110 Section 7.8)
pub(all) enum UpgradeError {
  Empty
  InvalidFormat
  InvalidProtocol
  InvalidVersion
} derive(Show, Eq)

///|
/// Upgrade protocol
pub(all) struct Protocol {
  name : String
  version : String?
} derive(Show, Eq)

///|
pub fn Protocol::name(self : Protocol) -> String {
  self.name
}

///|
pub fn Protocol::version(self : Protocol) -> String? {
  self.version
}

///|
pub fn Protocol::to_string(self : Protocol) -> String {
  match self.version {
    Some(v) => self.name + "/" + v
    None => self.name
  }
}

///|
/// Upgrade header (RFC 9110 Section 7.8)
pub(all) struct Upgrade {
  protocols : Array[Protocol]
} derive(Show, Eq)

///|
pub fn Upgrade::parse(input : String) -> Result[Upgrade, UpgradeError] {
  let s = upgrade_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = upgrade_split_string(s, ",")
  let protocols : Array[Protocol] = []
  let mut idx = 0
  while idx < parts.length() {
    let part = upgrade_trim_string(parts[idx])
    if part.length() == 0 {
      return Err(InvalidFormat)
    }
    let parse_result = upgrade_parse_protocol(part)
    match parse_result {
      Err(e) => return Err(e)
      Ok(p) => protocols.push(p)
    }
    idx = idx + 1
  }
  if protocols.length() == 0 {
    return Err(Empty)
  }
  Ok({ protocols, })
}

///|
pub fn Upgrade::protocols(self : Upgrade) -> Array[Protocol] {
  self.protocols
}

///|
pub fn Upgrade::has_protocol(self : Upgrade, protocol : String) -> Bool {
  let mut idx = 0
  while idx < self.protocols.length() {
    let p = self.protocols[idx]
    if p.name == upgrade_to_lower_case(protocol) {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
pub fn Upgrade::to_string(self : Upgrade) -> String {
  let strs = upgrade_map_protocols(self.protocols, fn(p) { p.to_string() })
  upgrade_join_strings(strs, ", ")
}

///|
/// Helper functions
///

///|
fn upgrade_parse_protocol(input : String) -> Result[Protocol, UpgradeError] {
  let slash_pos = upgrade_find_char_in(input, 0, 47) // /
  match slash_pos {
    Some(pos) => {
      let name = upgrade_trim_string(upgrade_string_slice(input, 0, pos))
      let rest = upgrade_string_slice_from(input, pos + 1)

      // Check for second slash (invalid)
      if upgrade_find_char_in(rest, 0, 47) != None { // /
        return Err(InvalidFormat)
      }
      let version = upgrade_trim_string(rest)
      if name.length() == 0 {
        return Err(InvalidProtocol)
      }
      if version.length() == 0 {
        return Err(InvalidVersion)
      }
      if !upgrade_is_valid_token(name) {
        return Err(InvalidProtocol)
      }
      if !upgrade_is_valid_token(version) {
        return Err(InvalidVersion)
      }
      Ok({
        name: upgrade_to_lower_case(name),
        version: Some(upgrade_to_lower_case(version)),
      })
    }
    None => {
      if !upgrade_is_valid_token(input) {
        return Err(InvalidProtocol)
      }
      Ok({ name: upgrade_to_lower_case(input), version: None })
    }
  }
}

///|
fn upgrade_is_valid_token(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    if !upgrade_is_token_char(upgrade_char_at(s, idx)) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn upgrade_is_token_char(b : Int) -> Bool {
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
fn upgrade_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn upgrade_to_lower_case(s : String) -> String {
  str_to_lower_case(s)
}

///|
fn upgrade_find_char_in(s : String, start : Int, target : Int) -> Int? {
  let mut idx = start
  while idx < s.length() {
    if upgrade_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn upgrade_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn upgrade_split_string(s : String, sep : String) -> Array[String] {
  str_split_string(s, sep)
}

///|
fn upgrade_string_slice(s : String, start : Int, end : Int) -> String {
  str_string_slice(s, start, end)
}

///|
fn upgrade_string_slice_from(s : String, start : Int) -> String {
  str_string_slice_from(s, start)
}

///|
fn[T, U] upgrade_map_protocols(arr : Array[T], f : (T) -> U) -> Array[U] {
  let result : Array[U] = []
  let mut idx = 0
  while idx < arr.length() {
    result.push(f(arr[idx]))
    idx = idx + 1
  }
  result
}

///|
fn upgrade_join_strings(strs : Array[String], sep : String) -> String {
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
