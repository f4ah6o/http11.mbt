///|
/// Digest Authentication (Authorization)
pub(all) struct DigestAuth {
  params : Array[(String, String)]
} derive(Eq)

///|
pub fn DigestAuth::parse(input : String) -> Result[DigestAuth, AuthError] {
  let s = au_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let params_str = match au_strip_scheme(s, "Digest") {
    None => Err(NotDigestScheme)
    Some(p) => if p.length() == 0 { Err(InvalidFormat) } else { Ok(p) }
  }
  match params_str {
    Err(e) => Err(e)
    Ok(ps) =>
      match au_parse_auth_params(ps) {
        Err(e) => Err(e)
        Ok(params) => {
          // Check required params: username, realm, nonce, uri, response
          if !au_has_required_params(params, [
              "username", "realm", "nonce", "uri", "response",
            ]) {
            return Err(MissingParameter)
          }
          Ok({ params, })
        }
      }
  }
}

///|
pub fn DigestAuth::param(self : DigestAuth, name : String) -> String? {
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
pub fn DigestAuth::username(self : DigestAuth) -> String? {
  self.param("username")
}

///|
pub fn DigestAuth::realm(self : DigestAuth) -> String? {
  self.param("realm")
}

///|
pub fn DigestAuth::nonce(self : DigestAuth) -> String? {
  self.param("nonce")
}

///|
pub fn DigestAuth::uri(self : DigestAuth) -> String? {
  self.param("uri")
}

///|
pub fn DigestAuth::response(self : DigestAuth) -> String? {
  self.param("response")
}

///|
pub fn DigestAuth::to_header_value(self : DigestAuth) -> String {
  "Digest " + au_format_auth_params(self.params)
}

///|
pub fn DigestAuth::to_string(self : DigestAuth) -> String {
  self.to_header_value()
}

///|
/// Digest Authentication Challenge (WWW-Authenticate)
pub(all) struct DigestChallenge {
  params : Array[(String, String)]
} derive(Eq)

///|
pub fn DigestChallenge::parse(
  input : String,
) -> Result[DigestChallenge, AuthError] {
  let s = au_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let params_str = match au_strip_scheme(s, "Digest") {
    None => Err(NotDigestScheme)
    Some(p) => if p.length() == 0 { Err(InvalidFormat) } else { Ok(p) }
  }
  match params_str {
    Err(e) => Err(e)
    Ok(ps) =>
      match au_parse_auth_params(ps) {
        Err(e) => Err(e)
        Ok(params) => {
          // Check required params: realm, nonce
          if !au_has_required_params(params, ["realm", "nonce"]) {
            return Err(MissingParameter)
          }
          Ok({ params, })
        }
      }
  }
}

///|
pub fn DigestChallenge::param(self : DigestChallenge, name : String) -> String? {
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
pub fn DigestChallenge::realm(self : DigestChallenge) -> String? {
  self.param("realm")
}

///|
pub fn DigestChallenge::nonce(self : DigestChallenge) -> String? {
  self.param("nonce")
}

///|
pub fn DigestChallenge::to_header_value(self : DigestChallenge) -> String {
  "Digest " + au_format_auth_params(self.params)
}

///|
pub fn DigestChallenge::to_string(self : DigestChallenge) -> String {
  self.to_header_value()
}
