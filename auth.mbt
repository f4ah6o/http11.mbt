///|
/// HTTP Authentication (Basic / Digest / Bearer)
/// RFC 7617 (Basic), RFC 7616 (Digest), RFC 6750 (Bearer)

///|

///|
/// Authentication error types
pub(all) enum AuthError {
  Empty
  InvalidFormat
  NotBasicScheme
  NotDigestScheme
  NotBearerScheme
  Base64DecodeError
  Utf8Error
  MissingColon
  InvalidParameter
  MissingParameter
  InvalidToken
} derive(Show, Eq)

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

///|

///|
/// Helper functions

///|

///|

///|
fn au_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = au_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = au_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  au_string_slice(s, start, end)
}

///|
fn au_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() || idx < 0 {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
}

///|
fn au_string_slice(s : String, start : Int, end : Int) -> String {
  if start < 0 {
    return ""
  }
  if end > s.length() {
    return au_string_slice_from(s, start)
  }
  if start >= end {
    return ""
  }
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
fn au_string_slice_from(s : String, start : Int) -> String {
  if start < 0 {
    return s
  }
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
fn au_find_char(s : String, target : Int) -> Int? {
  let mut idx = 0
  while idx < s.length() {
    if au_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn au_split_string(s : String, sep : String) -> Array[String] {
  let result : Array[String] = []
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
      result.push(au_string_slice(s, start, idx))
      start = idx + sep_len
      idx = start
    } else {
      idx = idx + 1
    }
  }
  result.push(au_string_slice_from(s, start))
  result
}

///|
fn au_to_lower_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = au_char_at(s, idx)
    let new_ch = if ch >= 65 && ch <= 90 { ch + 32 } else { ch }
    result = result + Int::unsafe_to_char(new_ch).to_string()
    idx = idx + 1
  }
  result
}

///|
fn au_starts_with_ignore_case(s : String, prefix : String) -> Bool {
  let s_lower = au_to_lower_case(s)
  let prefix_lower = au_to_lower_case(prefix)
  let prefix_len = prefix_lower.length()
  if s_lower.length() < prefix_len {
    return false
  }
  let mut idx = 0
  while idx < prefix_len {
    if s_lower[idx] != prefix_lower[idx] {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn au_strip_scheme(input : String, scheme : String) -> String? {
  let s = au_trim_string(input)
  let scheme_len = scheme.length()
  if s.length() <= scheme_len {
    return None
  }

  // Get prefix
  let prefix = au_string_slice(s, 0, scheme_len)
  if !au_starts_with_ignore_case(prefix, scheme) {
    return None
  }
  let rest = au_string_slice_from(s, scheme_len)
  if rest.length() == 0 {
    return None
  }
  let first_char = au_char_at(rest, 0)
  if first_char != 32 && first_char != 9 {
    return None
  }
  Some(au_trim_string(au_string_slice_from(rest, 1)))
}

///|
fn au_is_ows(b : Int) -> Bool {
  b == 32 || b == 9
}

///|
fn au_is_token_char(b : Int) -> Bool {
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
fn au_is_token68_char(b : Int) -> Bool {
  (b >= 65 && b <= 90) || // A-Z
  (b >= 97 && b <= 122) || // a-z
  (b >= 48 && b <= 57) || // 0-9
  b == 45 ||
  b == 46 ||
  b == 95 ||
  b == 126 ||
  b == 43 ||
  b == 47
}

///|
fn au_is_token68(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < value.length() {
    let ch = au_char_at(value, idx)
    if !au_is_token68_char(ch) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn au_parse_auth_params(
  input : String,
) -> Result[Array[(String, String)], AuthError] {
  let params : Array[(String, String)] = []
  let mut i = 0
  while i < input.length() {
    // Skip OWS
    while i < input.length() && au_is_ows(au_char_at(input, i)) {
      i = i + 1
    }
    // Check for comma
    if i < input.length() && au_char_at(input, i) == 44 {
      i = i + 1
      continue
    }
    // Skip OWS again
    while i < input.length() && au_is_ows(au_char_at(input, i)) {
      i = i + 1
    }
    if i >= input.length() {
      break
    }

    // Parse name (token)
    let name_start = i
    while i < input.length() && au_is_token_char(au_char_at(input, i)) {
      i = i + 1
    }
    if i == name_start {
      return Err(InvalidParameter)
    }
    let name = au_to_lower_case(au_string_slice(input, name_start, i))

    // Skip OWS
    while i < input.length() && au_is_ows(au_char_at(input, i)) {
      i = i + 1
    }
    if i >= input.length() || au_char_at(input, i) != 61 {
      return Err(InvalidParameter)
    }
    i = i + 1

    // Skip OWS
    while i < input.length() && au_is_ows(au_char_at(input, i)) {
      i = i + 1
    }
    if i >= input.length() {
      return Err(InvalidParameter)
    }

    // Parse value (token or quoted-string)
    let value = if au_char_at(input, i) == 34 {
      // Quoted string
      i = i + 1
      let mut value = ""
      let mut escaped = false
      let mut closed = false
      while i < input.length() {
        let ch = Int::unsafe_to_char(au_char_at(input, i))
        if escaped {
          value = value + ch.to_string()
          escaped = false
        } else if ch == '\\' {
          escaped = true
        } else if ch == '"' {
          i = i + 1
          closed = true
          break
        } else {
          value = value + ch.to_string()
        }
        i = i + 1
      }
      if escaped || !closed {
        return Err(InvalidParameter)
      }
      value
    } else {
      // Token
      let value_start = i
      while i < input.length() &&
            !au_is_ows(au_char_at(input, i)) &&
            au_char_at(input, i) != 44 {
        i = i + 1
      }
      let token = au_string_slice(input, value_start, i)
      if token.length() == 0 || !au_is_valid_token(token) {
        return Err(InvalidParameter)
      }
      token
    }
    params.push((name, value))

    // Skip OWS
    while i < input.length() && au_is_ows(au_char_at(input, i)) {
      i = i + 1
    }
    if i < input.length() && au_char_at(input, i) == 44 {
      i = i + 1
    }
  }
  if params.length() == 0 {
    return Err(InvalidFormat)
  }
  Ok(params)
}

///|
fn au_is_valid_token(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < value.length() {
    if !au_is_token_char(au_char_at(value, idx)) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn au_has_required_params(
  params : Array[(String, String)],
  required : Array[String],
) -> Bool {
  let mut idx = 0
  let mut found = 0
  while idx < required.length() {
    let req = au_to_lower_case(required[idx])
    let mut j = 0
    let mut found_this = false
    while j < params.length() {
      let (n, _) = params[j]
      if n == req {
        found_this = true
        break
      }
      j = j + 1
    }
    if found_this {
      found = found + 1
    }
    idx = idx + 1
  }
  found == required.length()
}

///|
fn au_needs_quoting(value : String) -> Bool {
  if value.length() == 0 {
    return true
  }
  let mut idx = 0
  while idx < value.length() {
    if !au_is_token_char(au_char_at(value, idx)) {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
fn au_escape_quotes(value : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < value.length() {
    let ch = value[idx]
    let ch_int = ch.to_int()
    if ch_int == 92 {
      // backslash
      result = result + "\\\\"
    } else if ch_int == 34 {
      // quote
      result = result + "\\\""
    } else {
      result = result + Int::unsafe_to_char(ch_int).to_string()
    }
    idx = idx + 1
  }
  result
}

///|
fn au_format_auth_params(params : Array[(String, String)]) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < params.length() {
    if idx > 0 {
      result = result + ", "
    }
    let (name, value) = params[idx]
    if au_needs_quoting(value) {
      result = result + name + "=\"" + au_escape_quotes(value) + "\""
    } else {
      result = result + name + "=" + value
    }
    idx = idx + 1
  }
  result
}

///|

///|
/// Base64 encoding/decoding (RFC 4648)

///|

///|
fn au_base64_encode(input : String) -> String {
  // Base64 alphabet
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  let mut result = ""
  let mut i = 0
  let len = input.length()
  while i < len {
    let b0 = au_char_at(input, i)
    let b1 = if i + 1 < len { au_char_at(input, i + 1) } else { 0 }
    let b2 = if i + 2 < len { au_char_at(input, i + 2) } else { 0 }

    // Combine 3 bytes into 24-bit number by shifting
    // b0 << 16 | b1 << 8 | b2
    let i0 = b0 >> 2
    let i1 = ((b0 & 3) << 4) | (b1 >> 4)
    let i2 = if i + 1 < len { ((b1 & 15) << 2) | (b2 >> 6) } else { -1 }
    let i3 = if i + 2 < len { b2 & 63 } else { -1 }

    // Get the character from alphabet at the calculated indices
    result = result + Int::unsafe_to_char(au_char_at(alphabet, i0)).to_string()
    result = result + Int::unsafe_to_char(au_char_at(alphabet, i1)).to_string()
    if i2 >= 0 {
      result = result +
        Int::unsafe_to_char(au_char_at(alphabet, i2)).to_string()
    } else {
      result = result + "="
    }
    if i3 >= 0 {
      result = result +
        Int::unsafe_to_char(au_char_at(alphabet, i3)).to_string()
    } else {
      result = result + "="
    }
    i = i + 3
  }
  result
}

///|
fn au_base64_decode_char(c : Int) -> Int? {
  if c >= 65 && c <= 90 {
    // A-Z
    Some(c - 65)
  } else if c >= 97 && c <= 122 {
    // a-z
    Some(c - 97 + 26)
  } else if c >= 48 && c <= 57 {
    // 0-9
    Some(c - 48 + 52)
  } else if c == 43 {
    // +
    Some(62)
  } else if c == 47 {
    // /
    Some(63)
  } else if c == 61 {
    // = (padding) - handled in decode loop
    Some(-2)
  } else if c == 32 || c == 9 || c == 10 || c == 13 {
    // Whitespace (skip in decoding loop)
    Some(-1)
  } else {
    None
  }
}

///|
fn au_base64_decode(input : String) -> Result[String, AuthError] {
  let mut result = ""
  let mut buf = 0
  let mut bits = 0
  let mut idx = 0
  while idx < input.length() {
    let ch = au_char_at(input, idx)
    match au_base64_decode_char(ch) {
      None => return Err(Base64DecodeError)
      Some(-1) => () // Skip whitespace
      Some(-2) =>
        // Padding character - end of input
        break
      Some(val) => {
        buf = buf * 64 + val
        bits = bits + 6
        if bits >= 8 {
          bits = bits - 8
          let byte = buf / au_pow2(bits)
          result = result + Int::unsafe_to_char(byte).to_string()
          buf = buf % au_pow2(bits)
        }
      }
    }
    idx = idx + 1
  }
  Ok(result)
}

///|
fn au_pow2(n : Int) -> Int {
  if n == 0 {
    1
  } else if n == 1 {
    2
  } else if n == 2 {
    4
  } else if n == 3 {
    8
  } else if n == 4 {
    16
  } else if n == 5 {
    32
  } else if n == 6 {
    64
  } else if n == 7 {
    128
  } else if n == 8 {
    256
  } else if n == 9 {
    512
  } else if n == 10 {
    1024
  } else if n == 11 {
    2048
  } else if n == 12 {
    4096
  } else if n == 13 {
    8192
  } else if n == 14 {
    16384
  } else if n == 15 {
    32768
  } else if n == 16 {
    65536
  } else if n == 17 {
    131072
  } else if n == 18 {
    262144
  } else if n == 19 {
    524288
  } else if n == 20 {
    1048576
  } else {
    1
  }
}
