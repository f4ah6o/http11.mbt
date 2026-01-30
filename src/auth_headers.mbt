///|
/// Authorization header
pub(all) enum Authorization {
  Basic(BasicAuth)
  Digest(DigestAuth)
  Bearer(BearerToken)
} derive(Eq)

///|
pub fn Authorization::parse(input : String) -> Result[Authorization, AuthError] {
  let s = au_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  if au_starts_with_ignore_case(s, "Basic ") {
    match BasicAuth::parse(s) {
      Ok(auth) => Ok(Basic(auth))
      Err(e) => Err(e)
    }
  } else if au_starts_with_ignore_case(s, "Digest ") {
    match DigestAuth::parse(s) {
      Ok(auth) => Ok(Digest(auth))
      Err(e) => Err(e)
    }
  } else if au_starts_with_ignore_case(s, "Bearer ") {
    match BearerToken::parse(s) {
      Ok(token) => Ok(Bearer(token))
      Err(e) => Err(e)
    }
  } else {
    Err(InvalidFormat)
  }
}

///|
pub fn Authorization::to_header_value(self : Authorization) -> String {
  match self {
    Basic(auth) => auth.to_header_value()
    Digest(auth) => auth.to_header_value()
    Bearer(token) => token.to_header_value()
  }
}

///|
pub fn Authorization::to_string(self : Authorization) -> String {
  self.to_header_value()
}

///|
/// WWW-Authenticate / Proxy-Authenticate challenge
pub(all) enum AuthChallenge {
  Basic(WwwAuthenticate)
  Digest(DigestChallenge)
  Bearer(BearerChallenge)
} derive(Eq)

///|
pub fn AuthChallenge::parse(input : String) -> Result[AuthChallenge, AuthError] {
  let s = au_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  if au_starts_with_ignore_case(s, "Basic ") {
    match WwwAuthenticate::parse(s) {
      Ok(auth) => Ok(Basic(auth))
      Err(e) => Err(e)
    }
  } else if au_starts_with_ignore_case(s, "Digest ") {
    match DigestChallenge::parse(s) {
      Ok(challenge) => Ok(Digest(challenge))
      Err(e) => Err(e)
    }
  } else if au_starts_with_ignore_case(s, "Bearer ") {
    match BearerChallenge::parse(s) {
      Ok(challenge) => Ok(Bearer(challenge))
      Err(e) => Err(e)
    }
  } else {
    Err(InvalidFormat)
  }
}

///|
pub fn AuthChallenge::to_header_value(self : AuthChallenge) -> String {
  match self {
    Basic(auth) => auth.to_header_value()
    Digest(challenge) => challenge.to_header_value()
    Bearer(challenge) => challenge.to_header_value()
  }
}

///|
pub fn AuthChallenge::to_string(self : AuthChallenge) -> String {
  self.to_header_value()
}

///|
/// Proxy-Authorization header
pub(all) struct ProxyAuthorization {
  auth : Authorization
} derive(Eq)

///|
pub fn ProxyAuthorization::parse(
  input : String,
) -> Result[ProxyAuthorization, AuthError] {
  match Authorization::parse(input) {
    Ok(auth) => Ok({ auth, })
    Err(e) => Err(e)
  }
}

///|
pub fn ProxyAuthorization::authorization(
  self : ProxyAuthorization,
) -> Authorization {
  self.auth
}

///|
pub fn ProxyAuthorization::to_header_value(self : ProxyAuthorization) -> String {
  self.auth.to_header_value()
}

///|
pub fn ProxyAuthorization::to_string(self : ProxyAuthorization) -> String {
  self.to_header_value()
}

///|
/// Proxy-Authenticate header
pub(all) struct ProxyAuthenticate {
  challenge : AuthChallenge
} derive(Eq)

///|
pub fn ProxyAuthenticate::parse(
  input : String,
) -> Result[ProxyAuthenticate, AuthError] {
  match AuthChallenge::parse(input) {
    Ok(challenge) => Ok({ challenge, })
    Err(e) => Err(e)
  }
}

///|
pub fn ProxyAuthenticate::challenge(self : ProxyAuthenticate) -> AuthChallenge {
  self.challenge
}

///|
pub fn ProxyAuthenticate::to_header_value(self : ProxyAuthenticate) -> String {
  self.challenge.to_header_value()
}

///|
pub fn ProxyAuthenticate::to_string(self : ProxyAuthenticate) -> String {
  self.to_header_value()
}
