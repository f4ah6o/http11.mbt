///|
/// Bearer Token (RFC 6750)
pub(all) struct BearerToken {
  token : String
} derive(Eq)

///|
pub fn BearerToken::parse(input : String) -> Result[BearerToken, AuthError] {
  let s = au_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  // Check for "Bearer" prefix (case-insensitive, must be followed by space)
  let is_bearer = if s.length() >= 6 {
    let prefix = au_string_slice(s, 0, 6)
    au_to_lower_case(prefix) == "bearer"
  } else {
    false
  }
  if !is_bearer {
    return Err(NotBearerScheme)
  }
  let token = match au_strip_scheme(s, "Bearer") {
    None => ""
    Some(t) => t
  }
  if token.length() == 0 {
    return Err(InvalidFormat)
  }
  if !au_is_token68(token) {
    return Err(InvalidToken)
  }
  Ok({ token, })
}

///|
pub fn BearerToken::token(self : BearerToken) -> String {
  self.token
}

///|
pub fn BearerToken::to_header_value(self : BearerToken) -> String {
  "Bearer " + self.token
}

///|
pub fn BearerToken::to_string(self : BearerToken) -> String {
  self.to_header_value()
}

///|
/// Bearer Challenge (WWW-Authenticate)
pub(all) struct BearerChallenge {
  params : Array[(String, String)]
} derive(Eq)

///|
pub fn BearerChallenge::parse(
  input : String,
) -> Result[BearerChallenge, AuthError] {
  let s = au_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let params_str = match au_strip_scheme(s, "Bearer") {
    None => Err(NotBearerScheme)
    Some(p) => if p.length() == 0 { Err(InvalidFormat) } else { Ok(p) }
  }
  match params_str {
    Err(e) => Err(e)
    Ok(ps) =>
      match au_parse_auth_params(ps) {
        Err(e) => Err(e)
        Ok(params) => Ok({ params, })
      }
  }
}

///|
pub fn BearerChallenge::param(self : BearerChallenge, name : String) -> String? {
  let lower_name = au_to_lower_case(name)
  let mut idx = 0
  while idx < self.params.length() {
    let (n, v) = self.params[idx]
    if n == lower_name {
      return Some(v)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn BearerChallenge::to_header_value(self : BearerChallenge) -> String {
  "Bearer " + au_format_auth_params(self.params)
}

///|
pub fn BearerChallenge::to_string(self : BearerChallenge) -> String {
  self.to_header_value()
}
