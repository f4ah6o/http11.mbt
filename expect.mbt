///|
/// Expect header parsing errors (RFC 9110 Section 10.1.1)
pub(all) enum ExpectError {
  Empty
  InvalidFormat
  InvalidToken
  InvalidValue
} derive(Show, Eq)

///|
/// Expectation item
pub(all) struct Expectation {
  token : String
  value : String?
} derive(Show, Eq)

///|
pub fn Expectation::token(self : Expectation) -> String {
  self.token
}

///|
pub fn Expectation::value(self : Expectation) -> String? {
  self.value
}

///|
pub fn Expectation::is_100_continue(self : Expectation) -> Bool {
  let lower = exp_to_lower_case(self.token)
  lower == "100-continue"
}

///|
pub fn Expectation::to_string(self : Expectation) -> String {
  match self.value {
    Some(v) =>
      if exp_needs_quoting(v) {
        self.token + "=\"" + exp_escape_quotes(v) + "\""
      } else {
        self.token + "=" + v
      }
    None => self.token
  }
}

///|
/// Expect header (RFC 9110 Section 10.1.1)
pub(all) struct Expect {
  items : Array[Expectation]
} derive(Show, Eq)

///|
pub fn Expect::parse(input : String) -> Result[Expect, ExpectError] {
  let s = exp_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = exp_split_with_quotes(s, 44) // ,
  let items : Array[Expectation] = []
  let mut part_idx = 0
  while part_idx < parts.length() {
    let part = exp_trim_string(parts[part_idx])
    if part.length() == 0 {
      return Err(InvalidFormat)
    }
    let parse_result = exp_parse_expectation(part)
    match parse_result {
      Err(e) => return Err(e)
      Ok((token, value)) => {
        if !exp_is_valid_token(token) {
          return Err(InvalidToken)
        }
        let lower_token = exp_to_lower_case(token)
        items.push({ token: lower_token, value })
        part_idx = part_idx + 1
      }
    }
  }
  if items.length() == 0 {
    return Err(Empty)
  }
  Ok({ items, })
}

///|
pub fn Expect::items(self : Expect) -> Array[Expectation] {
  self.items
}

///|
pub fn Expect::has_100_continue(self : Expect) -> Bool {
  let mut idx = 0
  while idx < self.items.length() {
    let item = self.items[idx]
    if item.is_100_continue() {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
pub fn Expect::to_string(self : Expect) -> String {
  let strs = exp_map_items(self.items, fn(e) { e.to_string() })
  exp_join_strings(strs, ", ")
}

///|
/// Helper functions
///

///|
fn exp_parse_expectation(
  input : String,
) -> Result[(String, String?), ExpectError] {
  let eq_pos = exp_find_char_in(input, 0, 61) // =
  match eq_pos {
    Some(pos) => {
      let token = exp_trim_string(exp_string_slice(input, 0, pos))
      if token.length() == 0 {
        return Err(InvalidFormat)
      }
      let value_str = exp_string_slice_from(input, pos + 1)
      let value_result = exp_parse_value(value_str)
      match value_result {
        Ok(v) => Ok((token, Some(v)))
        Err(e) => Err(e)
      }
    }
    None => Ok((input, None))
  }
}

///|
fn exp_parse_value(input : String) -> Result[String, ExpectError] {
  let s = exp_trim_string(input)
  if s.length() == 0 {
    return Err(InvalidValue)
  }
  if exp_char_at(s, 0) == 34 { // "
    let result = exp_parse_quoted_string(exp_string_slice_from(s, 1))
    match result {
      Ok((value, remaining)) => {
        let rest = exp_trim_string(remaining)
        if rest.length() != 0 {
          return Err(InvalidValue)
        }
        Ok(value)
      }
      Err(e) => Err(e)
    }
  } else {
    if !exp_is_valid_token(s) {
      return Err(InvalidValue)
    }
    Ok(s)
  }
}

///|
fn exp_parse_quoted_string(
  input : String,
) -> Result[(String, String), ExpectError] {
  let mut result = ""
  let mut escaped = false
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let ch = exp_char_at(input, idx)
    if escaped {
      result = result + Int::unsafe_to_char(ch).to_string()
      escaped = false
      idx = idx + 1
    } else if ch == 92 { // \
      escaped = true
      idx = idx + 1
    } else if ch == 34 { // "
      return Ok((result, exp_string_slice_from(input, idx + 1)))
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
      idx = idx + 1
    }
  }
  Err(InvalidValue)
}

///|
fn exp_split_with_quotes(input : String, delimiter : Int) -> Array[String] {
  let result : Array[String] = []
  let mut start = 0
  let mut in_quote = false
  let mut escaped = false
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let ch = exp_char_at(input, idx)
    if escaped {
      escaped = false
      idx = idx + 1
      continue
    }
    if ch == 92 && in_quote { // \
      escaped = true
      idx = idx + 1
      continue
    }
    if ch == 34 { // "
      in_quote = !in_quote
      idx = idx + 1
      continue
    }
    if ch == delimiter && !in_quote {
      result.push(exp_string_slice(input, start, idx))
      start = idx + 1
    }
    idx = idx + 1
  }
  result.push(exp_string_slice_from(input, start))
  result
}

///|
fn exp_is_valid_token(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    if !exp_is_token_char(exp_char_at(s, idx)) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn exp_is_token_char(b : Int) -> Bool {
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
  b == 48 ||
  b == 49 ||
  b == 50 ||
  b == 51 ||
  b == 52 ||
  b == 53 ||
  b == 54 ||
  b == 55 ||
  b == 56 ||
  b == 57 ||
  (b >= 65 && b <= 90) ||
  b == 94 ||
  b == 95 ||
  b == 96 ||
  (b >= 97 && b <= 122) ||
  b == 124 ||
  b == 126
}

///|
fn exp_needs_quoting(s : String) -> Bool {
  if s.length() == 0 {
    return true
  }
  let mut idx = 0
  while idx < s.length() {
    if !exp_is_token_char(exp_char_at(s, idx)) {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
fn exp_escape_quotes(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = exp_char_at(s, idx)
    if ch == 92 { // \
      result = result + "\\\\"
    } else if ch == 34 { // "
      result = result + "\\\""
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
    }
    idx = idx + 1
  }
  result
}

///|
fn exp_to_lower_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = exp_char_at(s, idx)
    if ch >= 65 && ch <= 90 { // A-Z
      result = result + Int::unsafe_to_char(ch + 32).to_string()
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
    }
    idx = idx + 1
  }
  result
}

///|
fn exp_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
}

///|
fn exp_find_char_in(s : String, start : Int, target : Int) -> Int? {
  let mut idx = start
  while idx < s.length() {
    if exp_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn exp_string_slice(s : String, start : Int, end : Int) -> String {
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
fn exp_string_slice_from(s : String, start : Int) -> String {
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
fn exp_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = exp_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = exp_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  exp_string_slice(s, start, end)
}

///|
fn[T, U] exp_map_items(arr : Array[T], f : (T) -> U) -> Array[U] {
  let result : Array[U] = []
  let mut idx = 0
  while idx < arr.length() {
    result.push(f(arr[idx]))
    idx = idx + 1
  }
  result
}

///|
fn exp_join_strings(strs : Array[String], sep : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < strs.length() {
    if idx > 0 {
      result = result + sep
    }
    result = result + strs[idx]
    idx = idx + 1
  }
  result
}
