///|
/// Helper functions

///|

///|
fn ck_parse_cookie_pair(pair : String) -> Result[(String, String), CookieError] {
  let eq_pos = ck_find_char(pair, 61) // =
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
        ck_char_at(value, value.length() - 1) == 34 { // "
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
  b == 94 ||
  b == 95 ||
  b == 96 ||
  b == 124 ||
  b == 126 ||
  (b >= 48 && b <= 57) ||
  (b >= 65 && b <= 90) ||
  (b >= 97 && b <= 122)
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
    if ch == 34 { // "
      current = current + "\""
      in_quotes = !in_quotes
      idx = idx + 1
    } else if ch == 59 && !in_quotes { // ;
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
  if ck_char_at(s, 0) == 45 { // -
    is_negative = true
    idx = 1
  }
  while idx < len {
    let ch = ck_char_at(s, idx)
    if ch >= 48 && ch <= 57 { // 0-9
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
  str_trim_string(s)
}

///|
fn ck_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
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
  str_string_slice(s, start, end)
}

///|
fn ck_string_slice_from(s : String, start : Int) -> String {
  str_string_slice_from(s, start)
}

///|
fn ck_split_string(s : String, sep : Int) -> Array[String] {
  str_split_char(s, sep)
}

///|
fn ck_to_lower_case(s : String) -> String {
  str_to_lower_case(s)
}
