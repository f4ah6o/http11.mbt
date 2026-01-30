///|
/// Cookie (name=value pair)
pub(all) struct Cookie {
  name : String
  value : String
} derive(Eq)

///|
pub fn Cookie::new(
  name : String,
  value : String,
) -> Result[Cookie, CookieError] {
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
  let parts = ck_split_string(s, 59) // ;
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
