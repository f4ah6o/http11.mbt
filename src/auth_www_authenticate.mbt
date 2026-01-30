///|
/// WWW-Authenticate header (Basic)
pub(all) struct WwwAuthenticate {
  realm : String
  charset : String?
} derive(Eq)

///|
pub fn WwwAuthenticate::basic(realm : String) -> WwwAuthenticate {
  { realm, charset: None }
}

///|
pub fn WwwAuthenticate::with_charset(
  self : WwwAuthenticate,
  charset : String,
) -> WwwAuthenticate {
  { realm: self.realm, charset: Some(charset) }
}

///|
pub fn WwwAuthenticate::parse(
  input : String,
) -> Result[WwwAuthenticate, AuthError] {
  let s = au_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  // Check for "Basic " prefix
  let params = if au_starts_with_ignore_case(s, "Basic ") {
    au_string_slice_from(s, 6)
  } else if au_starts_with_ignore_case(s, "basic ") {
    au_string_slice_from(s, 6)
  } else {
    return Err(NotBasicScheme)
  }
  let params = au_trim_string(params)
  let mut realm : String? = None
  let mut char_set : String? = None

  // Parse parameters
  let parts = au_split_string(params, ",")
  let mut idx = 0
  while idx < parts.length() {
    let part = au_trim_string(parts[idx])
    let eq_pos = au_find_char(part, 61)
    match eq_pos {
      Some(pos) => {
        let key = au_to_lower_case(
          au_trim_string(au_string_slice(part, 0, pos)),
        )
        let value = au_trim_string(au_string_slice_from(part, pos + 1))

        // Remove quotes
        let value = if value.length() >= 2 &&
          au_char_at(value, 0) == 34 &&
          au_char_at(value, value.length() - 1) == 34 {
          au_string_slice(value, 1, value.length() - 1)
        } else {
          value
        }
        if key == "realm" {
          realm = Some(value)
        } else if key == "charset" {
          char_set = Some(value)
        }
      }
      None => ()
    }
    idx = idx + 1
  }
  match realm {
    None => Err(InvalidFormat)
    Some(r) => Ok({ realm: r, charset: char_set })
  }
}

///|
pub fn WwwAuthenticate::realm(self : WwwAuthenticate) -> String {
  self.realm
}

///|
pub fn WwwAuthenticate::charset(self : WwwAuthenticate) -> String? {
  self.charset
}

///|
pub fn WwwAuthenticate::to_header_value(self : WwwAuthenticate) -> String {
  let mut result = "Basic realm=\"" + self.realm + "\""
  match self.charset {
    Some(c) => result = result + ", charset=\"" + c + "\""
    None => ()
  }
  result
}

///|
pub fn WwwAuthenticate::to_string(self : WwwAuthenticate) -> String {
  self.to_header_value()
}
