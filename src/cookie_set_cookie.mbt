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
pub fn SetCookie::new(
  name : String,
  value : String,
) -> Result[SetCookie, CookieError] {
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
    same_site: None,
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
        same_site: None,
      }
      let mut part_idx = 1
      while part_idx < parts.length() {
        let part = ck_trim_string(parts[part_idx])
        if part.length() > 0 {
          let eq_pos = ck_find_char(part, 61) // =
          match eq_pos {
            Some(pos) => {
              let attr_name = ck_to_lower_case(
                ck_trim_string(ck_string_slice(part, 0, pos)),
              )
              let attr_value = ck_trim_string(
                ck_string_slice_from(part, pos + 1),
              )
              match attr_name {
                "expires" => {
                  let date_result = HttpDate::parse(attr_value)
                  match date_result {
                    Ok(d) =>
                      set_cookie = {
                        name: set_cookie.name,
                        value: set_cookie.value,
                        expires: Some(d),
                        max_age: set_cookie.max_age,
                        domain: set_cookie.domain,
                        path: set_cookie.path,
                        secure: set_cookie.secure,
                        http_only: set_cookie.http_only,
                        same_site: set_cookie.same_site,
                      }
                    Err(_) => return Err(InvalidExpires)
                  }
                }
                "max-age" => {
                  let age_result = ck_parse_i64(attr_value)
                  match age_result {
                    Some(a) =>
                      set_cookie = {
                        name: set_cookie.name,
                        value: set_cookie.value,
                        expires: set_cookie.expires,
                        max_age: Some(a),
                        domain: set_cookie.domain,
                        path: set_cookie.path,
                        secure: set_cookie.secure,
                        http_only: set_cookie.http_only,
                        same_site: set_cookie.same_site,
                      }
                    None => return Err(InvalidMaxAge)
                  }
                }
                "domain" =>
                  set_cookie = {
                    name: set_cookie.name,
                    value: set_cookie.value,
                    expires: set_cookie.expires,
                    max_age: set_cookie.max_age,
                    domain: Some(attr_value),
                    path: set_cookie.path,
                    secure: set_cookie.secure,
                    http_only: set_cookie.http_only,
                    same_site: set_cookie.same_site,
                  }
                "path" =>
                  set_cookie = {
                    name: set_cookie.name,
                    value: set_cookie.value,
                    expires: set_cookie.expires,
                    max_age: set_cookie.max_age,
                    domain: set_cookie.domain,
                    path: Some(attr_value),
                    secure: set_cookie.secure,
                    http_only: set_cookie.http_only,
                    same_site: set_cookie.same_site,
                  }
                "samesite" => {
                  let ss_result = ck_parse_same_site(attr_value)
                  match ss_result {
                    Ok(ss) =>
                      set_cookie = {
                        name: set_cookie.name,
                        value: set_cookie.value,
                        expires: set_cookie.expires,
                        max_age: set_cookie.max_age,
                        domain: set_cookie.domain,
                        path: set_cookie.path,
                        secure: set_cookie.secure,
                        http_only: set_cookie.http_only,
                        same_site: Some(ss),
                      }
                    Err(_) => return Err(InvalidSameSite)
                  }
                }
                _ => {
                  let _ = ()
                }
              }
            }
            None => {
              let part_lower = ck_to_lower_case(part)
              match part_lower {
                "secure" =>
                  set_cookie = {
                    name: set_cookie.name,
                    value: set_cookie.value,
                    expires: set_cookie.expires,
                    max_age: set_cookie.max_age,
                    domain: set_cookie.domain,
                    path: set_cookie.path,
                    secure: true,
                    http_only: set_cookie.http_only,
                    same_site: set_cookie.same_site,
                  }
                "httponly" =>
                  set_cookie = {
                    name: set_cookie.name,
                    value: set_cookie.value,
                    expires: set_cookie.expires,
                    max_age: set_cookie.max_age,
                    domain: set_cookie.domain,
                    path: set_cookie.path,
                    secure: set_cookie.secure,
                    http_only: true,
                    same_site: set_cookie.same_site,
                  }
                _ => {
                  let _ = ()
                }
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
pub fn SetCookie::with_expires(
  self : SetCookie,
  expires : HttpDate,
) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: Some(expires),
    max_age: self.max_age,
    domain: self.domain,
    path: self.path,
    secure: self.secure,
    http_only: self.http_only,
    same_site: self.same_site,
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
    same_site: self.same_site,
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
    same_site: self.same_site,
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
    same_site: self.same_site,
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
    secure,
    http_only: self.http_only,
    same_site: self.same_site,
  }
}

///|
pub fn SetCookie::with_http_only(
  self : SetCookie,
  http_only : Bool,
) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: self.expires,
    max_age: self.max_age,
    domain: self.domain,
    path: self.path,
    secure: self.secure,
    http_only,
    same_site: self.same_site,
  }
}

///|
pub fn SetCookie::with_same_site(
  self : SetCookie,
  same_site : SameSite,
) -> SetCookie {
  {
    name: self.name,
    value: self.value,
    expires: self.expires,
    max_age: self.max_age,
    domain: self.domain,
    path: self.path,
    secure: self.secure,
    http_only: self.http_only,
    same_site: Some(same_site),
  }
}

///|
pub fn SetCookie::to_string(self : SetCookie) -> String {
  let mut result = self.name + "=" + self.value
  match self.expires {
    Some(e) => result = result + "; Expires=" + e.to_string()
    None => {
      let _ = ()
    }
  }
  match self.max_age {
    Some(a) => result = result + "; Max-Age=" + a.to_string()
    None => {
      let _ = ()
    }
  }
  match self.domain {
    Some(d) => result = result + "; Domain=" + d
    None => {
      let _ = ()
    }
  }
  match self.path {
    Some(p) => result = result + "; Path=" + p
    None => {
      let _ = ()
    }
  }
  if self.secure {
    result = result + "; Secure"
  }
  if self.http_only {
    result = result + "; HttpOnly"
  }
  match self.same_site {
    Some(ss) => result = result + "; SameSite=" + ss.to_string()
    None => {
      let _ = ()
    }
  }
  result
}
