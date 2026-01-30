///|
/// Basic Authentication (RFC 7617)
pub(all) struct BasicAuth {
  username : String
  password : String
} derive(Eq)

///|
pub fn BasicAuth::new(username : String, password : String) -> BasicAuth {
  { username, password }
}

///|
pub fn BasicAuth::parse(input : String) -> Result[BasicAuth, AuthError] {
  let s = au_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  // Check for "Basic " prefix (case-insensitive)
  let credentials = if au_starts_with_ignore_case(s, "Basic ") {
    au_string_slice_from(s, 6)
  } else if au_starts_with_ignore_case(s, "basic ") {
    au_string_slice_from(s, 6)
  } else {
    return Err(NotBasicScheme)
  }
  let credentials = au_trim_string(credentials)
  if credentials.length() == 0 {
    return Err(InvalidFormat)
  }

  // Base64 decode
  match au_base64_decode(credentials) {
    Err(e) => Err(e)
    Ok(decoded) => {
      // user:password format
      let colon_pos = au_find_char(decoded, 58)
      match colon_pos {
        None => Err(MissingColon)
        Some(pos) => {
          let username = au_string_slice(decoded, 0, pos)
          let password = au_string_slice_from(decoded, pos + 1)
          Ok({ username, password })
        }
      }
    }
  }
}

///|
pub fn BasicAuth::username(self : BasicAuth) -> String {
  self.username
}

///|
pub fn BasicAuth::password(self : BasicAuth) -> String {
  self.password
}

///|
pub fn BasicAuth::to_header_value(self : BasicAuth) -> String {
  let credentials = self.username + ":" + self.password
  "Basic " + au_base64_encode(credentials)
}

///|
pub fn BasicAuth::to_string(self : BasicAuth) -> String {
  self.to_header_value()
}
