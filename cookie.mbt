///|
/// Cookie parsing errors (RFC 6265)
pub(all) enum CookieError {
  Empty
  InvalidFormat
  InvalidName
  InvalidValue
  InvalidAttribute
  InvalidExpires
  InvalidMaxAge
  InvalidSameSite
} derive(Show, Eq)

///|
/// Cookie (name=value pair)
pub(all) struct Cookie {
  name : String
  value : String
} derive(Eq)

///|
pub fn Cookie::new(name : String, value : String) -> Result[Cookie, CookieError] {
  if name.length() == 0 || !ck_is_valid_cookie_name(name) {
    return Err(InvalidName)
  }
  if !ck_is_valid_cookie_value(value) {
    return Err(InvalidValue)
  }
  Ok({ name, value })
}

///|
pub fn Cookie::parse(input : String) -> Result[Array[Cookie], CookieError] {
  let s = ck_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  let mut cookies : Array[Cookie] = []
  let parts = ck_split_string(s, 59)  // ;

  let mut idx = 0
  while idx < parts.length() {
    let pair = ck_trim_string(parts[idx])
    if pair.length() > 0 {
      let parse_result = ck_parse_cookie_pair(pair)
      match parse_result {
        Ok((n, v)) => {
          let new_cookies = []
          let mut j = 0
          while j < cookies.length() {
            new_cookies.push(cookies[j])
            j = j + 1
          }
          new_cookies.push({ name: n, value: v })
          cookies = new_cookies
        }
        Err(e) => return Err(e)
      }
    }
    idx = idx + 1
  }

  if cookies.length() == 0 {
    return Err(Empty)
  }

  Ok(cookies)
}

///|
pub fn Cookie::name(self : Cookie) -> String {
  self.name
}

///|
pub fn Cookie::value(self : Cookie) -> String {
  self.value
}

///|
pub fn Cookie::to_string(self : Cookie) -> String {
  self.name + "=" + self.value
}

///|
/// SameSite attribute
pub(all) enum SameSite {
  Strict
  Lax
  SameSiteNone
} derive(Eq)

///|
pub fn SameSite::to_string(self : SameSite) -> String {
  match self {
    Strict => "Strict"
    Lax => "Lax"
    SameSiteNone => "None"
  }
}

///|
/// Set-Cookie header
pub(all) struct SetCookie {
  name : String
  value : String
  expires : HttpDate?
  max_age : Int?
  domain : String?
  path : String?
  secure : Bool
  http_only : Bool
  same_site : SameSite?
} derive(Eq)

///|
pub fn SetCookie::new(name : String, value : String) -> Result[SetCookie, CookieError] {
  if name.length() == 0 || !ck_is_valid_cookie_name(name) {
    return Err(InvalidName)
  }
  if !ck_is_valid_cookie_value(value) {
    return Err(InvalidValue)
  }
  Ok({
    name,
    value,
    expires: None,
    max_age: None,
    domain: None,
    path: None,
    secure: false,
    http_only: false,
    same_site: None
  })
}

///|
pub fn SetCookie::parse(input : String) -> Result[SetCookie, CookieError] {
  let s = ck_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  let parts = ck_split_params(s)
  if parts.length() == 0 {
    return Err(InvalidFormat)
  }

  let first = ck_trim_string(parts[0])
  let parse_result = ck_parse_cookie_pair(first)
  match parse_result {
    Err(e) => return Err(e)
    Ok((name, value)) => {
      let mut set_cookie = {
        name,
        value,
        expires: None,
        max_age: None,
        domain: None,
        path: None,
        secure: false,
        http_only: false,
        same_site: None
      }

      let mut part_idx = 1
      while part_idx < parts.length() {
        let part = ck_trim_string(parts[part_idx])
        if part.length() > 0 {
          let eq_pos = ck_find_char(part, 61)  // =
          match eq_pos {
            Some(pos) => {
              let attr_name = ck_to_lower_case(ck_trim_string(ck_string_slice(part, 0, pos)))
              let attr_value = ck_trim_string(ck_string_slice_from(part, pos + 1))

              match attr_name {
                "expires" => {
                  let date_result = HttpDate::parse(attr_value)
                  match date_result {
                    Ok(d) => {
                      set_cookie = {
                        name: set_cookie.name,
                        value: set_cookie.value,
                        expires: Some(d),
                        max_age: set_cookie.max_age,
                        domain: set_cookie.domain,
                        path: set_cookie.path,
                        secure: set_cookie.secure,
                        http_only: set_cookie.http_only,
                        same_site: set_cookie.same_site
                      }
                    }
                    Err(_) => return Err(InvalidExpires)
                  }
                }
                "max-age" => {
                  let age_result = ck_parse_i64(attr_value)
                  match age_result {
                    Some(a) => {
                      set_cookie = {
                        name: set_cookie.name,
                        value: set_cookie.value,
                        expires: set_cookie.expires,
                        max_age: Some(a),
                        domain: set_cookie.domain,
                        path: set_cookie.path,
                        secure: set_cookie.secure,
                        http_only: set_cookie.http_only,
                        same_site: set_cookie.same_site
                      }
                    }
                    None => return Err(InvalidMaxAge)
                  }
                }
                "domain" => {
                  set_cookie = {
                    name: set_cookie.name,
                    value: set_cookie.value,
                    expires: set_cookie.expires,
                    max_age: set_cookie.max_age,
                    domain: Some(attr_value),
                    path: set_cookie.path,
                    secure: set_cookie.secure,
                    http_only: set_cookie.http_only,
                    same_site: set_cookie.same_site
                  }
                }
                "path" => {
                  set_cookie = {
                    name: set_cookie.name,
                    value: set_cookie.value,
                    expires: set_cookie.expires,
                    max_age: set_cookie.max_age,
                    domain: set_cookie.domain,
                    path: Some(attr_value),
                    secure: set_cookie.secure,
                    http_only: set_cookie.http_only,
                    same_site: set_cookie.same_site
                  }
                }
                "samesite" => {
                  let ss_result = ck_parse_same_site(attr_value)
                  match ss_result {
                    Ok(ss) => {
                      set_cookie = {
                        name: set_cookie.name,
                        value: set_cookie.value,
                        expires: set_cookie.expires,
                        max_age: set_cookie.max_age,
                        domain: set_cookie.domain,
                        path: set_cookie.path,
                        secure: set_cookie.secure,
                        http_only: set_cookie.http_only,
                        same_site: Some(ss)
                      }
                    }
                    Err(_) => return Err(InvalidSameSite)
                  }
                }
                _ => { let _ = () }
              }
            }
            None => {
              let part_lower = ck_to_lower_case(part)
              match part_lower {
                "secure" => {
                  set_cookie = {
                    name: set_cookie.name,
                    value: set_cookie.value,
                    expires: set_cookie.expires,
                    max_age: set_cookie.max_age,
                    domain: set_cookie.domain,
                    path: set_cookie.path,
                    secure: true,
                    http_only: set_cookie.http_only,
                    same_site: set_cookie.same_site
                  }
                }
                "httponly" => {
                  set_cookie = {
                    name: set_cookie.name,
                    value: set_cookie.value,
                    expires: set_cookie.expires,
                    max_age: set_cookie.max_age,
                    domain: set_cookie.domain,
                    path: set_cookie.path,
                    secure: set_cookie.secure,
                    http_only: true,
                    same_site: set_cookie.same_site
                  }
                }
                _ => { let _ = () }
              }
            }
          }
        }
        part_idx = part_idx + 1
      }

      Ok(set_cookie)
    }
  }
}

///|
pub fn SetCookie::name(self : SetCookie) -> String {
  self.name
}

///|
pub fn SetCookie::value(self : SetCookie) -> String {
  self.value
}

///|
pub fn SetCookie::expires(self : SetCookie) -> HttpDate? {
  self.expires
}

///|
pub fn SetCookie::max_age(self : SetCookie) -> Int? {
  self.max_age
}

///|
pub fn SetCookie::domain(self : SetCookie) -> String? {
  self.domain
}

///|
pub fn SetCookie::path(self : SetCookie) -> String? {
  self.path
}

///|
pub fn SetCookie::secure(self : SetCookie) -> Bool {
  self.secure
}

///|
pub fn SetCookie::http_only(self : SetCookie) -> Bool {
  self.http_only
}

///|
pub fn SetCookie::same_site(self : SetCookie) -> SameSite? {
  self.same_site
}

///|
pub fn SetCookie::with_expires(self : SetCookie, expires : HttpDate) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: Some(expires),
    max_age: self.max_age,
    domain: self.domain,
    path: self.path,
    secure: self.secure,
    http_only: self.http_only,
    same_site: self.same_site
  }
}

///|
pub fn SetCookie::with_max_age(self : SetCookie, max_age : Int) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: self.expires,
    max_age: Some(max_age),
    domain: self.domain,
    path: self.path,
    secure: self.secure,
    http_only: self.http_only,
    same_site: self.same_site
  }
}

///|
pub fn SetCookie::with_domain(self : SetCookie, domain : String) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: self.expires,
    max_age: self.max_age,
    domain: Some(domain),
    path: self.path,
    secure: self.secure,
    http_only: self.http_only,
    same_site: self.same_site
  }
}

///|
pub fn SetCookie::with_path(self : SetCookie, path : String) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: self.expires,
    max_age: self.max_age,
    domain: self.domain,
    path: Some(path),
    secure: self.secure,
    http_only: self.http_only,
    same_site: self.same_site
  }
}

///|
pub fn SetCookie::with_secure(self : SetCookie, secure : Bool) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: self.expires,
    max_age: self.max_age,
    domain: self.domain,
    path: self.path,
    secure: secure,
    http_only: self.http_only,
    same_site: self.same_site
  }
}

///|
pub fn SetCookie::with_http_only(self : SetCookie, http_only : Bool) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: self.expires,
    max_age: self.max_age,
    domain: self.domain,
    path: self.path,
    secure: self.secure,
    http_only: http_only,
    same_site: self.same_site
  }
}

///|
pub fn SetCookie::with_same_site(self : SetCookie, same_site : SameSite) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: self.expires,
    max_age: self.max_age,
    domain: self.domain,
    path: self.path,
    secure: self.secure,
    http_only: self.http_only,
    same_site: Some(same_site)
  }
}

///|
pub fn SetCookie::to_string(self : SetCookie) -> String {
  let mut result = self.name + "=" + self.value

  match self.expires {
    Some(e) => result = result + "; Expires=" + e.to_string()
    None => { let _ = () }
  }

  match self.max_age {
    Some(a) => result = result + "; Max-Age=" + a.to_string()
    None => { let _ = () }
  }

  match self.domain {
    Some(d) => result = result + "; Domain=" + d
    None => { let _ = () }
  }

  match self.path {
    Some(p) => result = result + "; Path=" + p
    None => { let _ = () }
  }

  if self.secure {
    result = result + "; Secure"
  }

  if self.http_only {
    result = result + "; HttpOnly"
  }

  match self.same_site {
    Some(ss) => result = result + "; SameSite=" + ss.to_string()
    None => { let _ = () }
  }

  result
}

///|
/// Helper functions
///|

///|
fn ck_parse_cookie_pair(pair : String) -> Result[(String, String), CookieError] {
  let eq_pos = ck_find_char(pair, 61)  // =
  match eq_pos {
    None => return Err(InvalidFormat)
    Some(pos) => {
      let name = ck_trim_string(ck_string_slice(pair, 0, pos))
      let value = ck_trim_string(ck_string_slice_from(pair, pos + 1))

      if name.length() == 0 {
        return Err(InvalidName)
      }

      if !ck_is_valid_cookie_name(name) {
        return Err(InvalidName)
      }

      let value = if value.length() >= 2 &&
                     ck_char_at(value, 0) == 34 &&
                     ck_char_at(value, value.length() - 1) == 34 {  // "
        ck_string_slice(value, 1, value.length() - 1)
      } else {
        value
      }

      Ok((name, value))
    }
  }
}

///|
fn ck_is_valid_cookie_name(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    let ch = ck_char_at(s, idx)
    if !ck_is_token_char(ch) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn ck_is_valid_cookie_value(s : String) -> Bool {
  let mut idx = 0
  while idx < s.length() {
    let ch = ck_char_at(s, idx)
    if !ck_is_cookie_octet(ch) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn ck_is_token_char(b : Int) -> Bool {
  b == 33 || b == 35 || b == 36 || b == 37 || b == 38 || b == 39 || b == 42 ||
  b == 43 || b == 45 || b == 46 || b == 94 || b == 95 || b == 96 || b == 124 ||
  b == 126 || (b >= 48 && b <= 57) || (b >= 65 && b <= 90) || (b >= 97 && b <= 122)
}

///|
fn ck_is_cookie_octet(b : Int) -> Bool {
  b == 33 ||
  (b >= 35 && b <= 43) ||
  (b >= 45 && b <= 58) ||
  (b >= 60 && b <= 91) ||
  (b >= 93 && b <= 126)
}

///|
fn ck_parse_same_site(s : String) -> Result[SameSite, CookieError] {
  let s_lower = ck_to_lower_case(s)
  match s_lower {
    "strict" => Ok(Strict)
    "lax" => Ok(Lax)
    "none" => Ok(SameSiteNone)
    _ => Err(InvalidSameSite)
  }
}

///|
fn ck_split_params(input : String) -> Array[String] {
  let mut result : Array[String] = []
  let mut current = ""
  let mut in_quotes = false
  let mut idx = 0
  let len = input.length()

  while idx < len {
    let ch = ck_char_at(input, idx)
    if ch == 34 {  // "
      current = current + "\""
      in_quotes = !in_quotes
      idx = idx + 1
    } else if ch == 59 && !in_quotes {  // ;
      let new_result = []
      let mut j = 0
      while j < result.length() {
        new_result.push(result[j])
        j = j + 1
      }
      new_result.push(current)
      result = new_result
      current = ""
      idx = idx + 1
    } else {
      current = current + Int::unsafe_to_char(ch).to_string()
      idx = idx + 1
    }
  }

  if current.length() > 0 {
    let new_result = []
    let mut j = 0
    while j < result.length() {
      new_result.push(result[j])
      j = j + 1
    }
    new_result.push(current)
    result = new_result
  }

  result
}

///|
fn ck_parse_i64(s : String) -> Int? {
  let mut result = 0
  let mut idx = 0
  let len = s.length()
  let mut is_negative = false

  if len == 0 {
    return None
  }

  if ck_char_at(s, 0) == 45 {  // -
    is_negative = true
    idx = 1
  }

  while idx < len {
    let ch = ck_char_at(s, idx)
    if ch >= 48 && ch <= 57 {  // 0-9
      result = result * 10 + (ch - 48)
    } else {
      return None
    }
    idx = idx + 1
  }

  if is_negative {
    Some(-result)
  } else {
    Some(result)
  }
}

///|
fn ck_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = ck_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = ck_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  ck_string_slice(s, start, end)
}

///|
fn ck_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
}

///|
fn ck_find_char(s : String, target : Int) -> Int? {
  let mut idx = 0
  while idx < s.length() {
    if ck_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn ck_string_slice(s : String, start : Int, end : Int) -> String {
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
fn ck_string_slice_from(s : String, start : Int) -> String {
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
fn ck_split_string(s : String, sep : Int) -> Array[String] {
  let mut result = []
  let mut start = 0
  let mut idx = 0

  while idx < s.length() {
    let ch = ck_char_at(s, idx)
    if ch == sep {
      let new_result = []
      let mut j = 0
      while j < result.length() {
        new_result.push(result[j])
        j = j + 1
      }
      new_result.push(ck_string_slice(s, start, idx))
      result = new_result
      start = idx + 1
    }
    idx = idx + 1
  }

  let new_result = []
  let mut j = 0
  while j < result.length() {
    new_result.push(result[j])
    j = j + 1
  }
  new_result.push(ck_string_slice_from(s, start))
  result = new_result
  result
}

///|
fn ck_to_lower_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = ck_char_at(s, idx)
    if ch >= 65 && ch <= 90 {  // A-Z
      result = result + Int::unsafe_to_char(ch + 32).to_string()
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
    }
    idx = idx + 1
  }
  result
}
