///|
/// Content-Type header parsing errors (RFC 9110 Section 8.3)
pub(all) enum ContentTypeError {
  Empty
  InvalidMediaType
  InvalidParameter
  UnterminatedQuote
} derive(Show, Eq)

///|
/// Content-Type header (RFC 9110 Section 8.3)
pub(all) struct ContentType {
  media_type : String
  subtype : String
  parameters : Array[(String, String)]
} derive(Eq)

///|
pub fn ContentType::parse(
  input : String,
) -> Result[ContentType, ContentTypeError] {
  let s = ct_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let (media_part, rest) = ct_split_at_semicolon(s)
  let parse_result = ct_parse_media_type(media_part)
  match parse_result {
    Err(e) => return Err(e)
    Ok((mt, st)) => {
      let params_result = ct_parse_parameters(rest)
      match params_result {
        Err(e) => return Err(e)
        Ok(params) =>
          Ok({
            media_type: ct_to_lower_case(mt),
            subtype: ct_to_lower_case(st),
            parameters: params,
          })
      }
    }
  }
}

///|
pub fn ContentType::new(media_type : String, subtype : String) -> ContentType {
  {
    media_type: ct_to_lower_case(media_type),
    subtype: ct_to_lower_case(subtype),
    parameters: [],
  }
}

///|
pub fn ContentType::with_parameter(
  self : ContentType,
  name : String,
  value : String,
) -> ContentType {
  let new_params = []
  let mut idx = 0
  while idx < self.parameters.length() {
    new_params.push(self.parameters[idx])
    idx = idx + 1
  }
  new_params.push((ct_to_lower_case(name), value))
  { media_type: self.media_type, subtype: self.subtype, parameters: new_params }
}

///|
pub fn ContentType::media_type(self : ContentType) -> String {
  self.media_type
}

///|
pub fn ContentType::subtype(self : ContentType) -> String {
  self.subtype
}

///|
pub fn ContentType::mime_type(self : ContentType) -> String {
  self.media_type + "/" + self.subtype
}

///|
pub fn ContentType::parameter(self : ContentType, name : String) -> String? {
  let name_lower = ct_to_lower_case(name)
  let mut idx = 0
  while idx < self.parameters.length() {
    let (n, v) = self.parameters[idx]
    if n == name_lower {
      return Some(v)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn ContentType::parameters(self : ContentType) -> Array[(String, String)] {
  self.parameters
}

///|
pub fn ContentType::charset(self : ContentType) -> String? {
  self.parameter("charset")
}

///|
pub fn ContentType::boundary(self : ContentType) -> String? {
  self.parameter("boundary")
}

///|
pub fn ContentType::is_text(self : ContentType) -> Bool {
  self.media_type == "text"
}

///|
pub fn ContentType::is_json(self : ContentType) -> Bool {
  self.media_type == "application" && self.subtype == "json"
}

///|
pub fn ContentType::is_multipart(self : ContentType) -> Bool {
  self.media_type == "multipart"
}

///|
pub fn ContentType::is_form_data(self : ContentType) -> Bool {
  self.media_type == "multipart" && self.subtype == "form-data"
}

///|
pub fn ContentType::is_form_urlencoded(self : ContentType) -> Bool {
  self.media_type == "application" && self.subtype == "x-www-form-urlencoded"
}

///|
pub fn ContentType::to_string(self : ContentType) -> String {
  let mut result = self.media_type + "/" + self.subtype
  let mut idx = 0
  while idx < self.parameters.length() {
    let (name, value) = self.parameters[idx]
    if ct_needs_quoting(value) {
      result = result + "; " + name + "=\"" + ct_escape_quotes(value) + "\""
    } else {
      result = result + "; " + name + "=" + value
    }
    idx = idx + 1
  }
  result
}

///|
/// Helper functions
///

///|
fn ct_split_at_semicolon(input : String) -> (String, String) {
  let semicolon_pos = ct_find_char(input, 59) // ;
  match semicolon_pos {
    Some(pos) =>
      (
        ct_trim_string(ct_string_slice(input, 0, pos)),
        ct_trim_string(ct_string_slice_from(input, pos + 1)),
      )
    None => (ct_trim_string(input), "")
  }
}

///|
fn ct_parse_media_type(
  input : String,
) -> Result[(String, String), ContentTypeError] {
  let s = ct_trim_string(input)
  if s.length() == 0 {
    return Err(InvalidMediaType)
  }
  let slash_pos = ct_find_char(s, 47) // /
  match slash_pos {
    None => return Err(InvalidMediaType)
    Some(pos) => {
      let mt = ct_trim_string(ct_string_slice(s, 0, pos))
      let st = ct_trim_string(ct_string_slice_from(s, pos + 1))
      if mt.length() == 0 || st.length() == 0 {
        return Err(InvalidMediaType)
      }
      if !ct_is_valid_token(mt) || !ct_is_valid_token(st) {
        return Err(InvalidMediaType)
      }
      Ok((mt, st))
    }
  }
}

///|
fn ct_parse_parameters(
  input : String,
) -> Result[Array[(String, String)], ContentTypeError] {
  let mut params : Array[(String, String)] = []
  let mut rest = ct_trim_string(input)
  while rest.length() > 0 {
    // Skip semicolon
    rest = ct_trim_string(ct_skip_leading_char(rest, 59)) // ;
    if rest.length() == 0 {
      break
    }

    // Find =
    let eq_pos = ct_find_char(rest, 61) // =
    match eq_pos {
      None => return Err(InvalidParameter)
      Some(pos) => {
        let name = ct_trim_string(ct_string_slice(rest, 0, pos))
        if name.length() == 0 || !ct_is_valid_token(name) {
          return Err(InvalidParameter)
        }
        let value_part = ct_trim_string(ct_string_slice_from(rest, pos + 1))

        // Parse value (quoted or token)
        let parse_result = ct_parse_value(value_part)
        match parse_result {
          Ok((value, remaining)) => {
            let new_params = []
            let mut idx = 0
            while idx < params.length() {
              new_params.push(params[idx])
              idx = idx + 1
            }
            new_params.push((ct_to_lower_case(name), value))
            params = new_params
            rest = ct_trim_string(ct_skip_leading_char(remaining, 59)) // ;
          }
          Err(e) => return Err(e)
        }
      }
    }
  }
  Ok(params)
}

///|
fn ct_parse_value(input : String) -> Result[(String, String), ContentTypeError] {
  if input.length() > 0 && ct_char_at(input, 0) == 34 { // "
    let after_quote = ct_string_slice_from(input, 1)
    ct_parse_quoted_string(after_quote)
  } else {
    Ok(ct_parse_token_value(input))
  }
}

///|
fn ct_parse_quoted_string(
  input : String,
) -> Result[(String, String), ContentTypeError] {
  let mut result = ""
  let mut escaped = false
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let ch = ct_char_at(input, idx)
    if escaped {
      result = result + Int::unsafe_to_char(ch).to_string()
      escaped = false
      idx = idx + 1
    } else if ch == 92 { // \
      escaped = true
      idx = idx + 1
    } else if ch == 34 { // "
      return Ok((result, ct_string_slice_from(input, idx + 1)))
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
      idx = idx + 1
    }
  }
  Err(UnterminatedQuote)
}

///|
fn ct_parse_token_value(input : String) -> (String, String) {
  let mut end = 0
  while end < input.length() {
    let ch = ct_char_at(input, end)
    if ch == 59 || ch == 32 || ch == 9 || ch == 10 || ch == 13 { // ; or whitespace
      break
    }
    end = end + 1
  }
  (ct_string_slice(input, 0, end), ct_string_slice_from(input, end))
}

///|
fn ct_is_valid_token(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    if !ct_is_token_char(ct_char_at(s, idx)) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn ct_is_token_char(b : Int) -> Bool {
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
fn ct_needs_quoting(s : String) -> Bool {
  let mut idx = 0
  while idx < s.length() {
    if !ct_is_token_char(ct_char_at(s, idx)) {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
fn ct_escape_quotes(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = ct_char_at(s, idx)
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
fn ct_to_lower_case(s : String) -> String {
  str_to_lower_case(s)
}

///|
fn ct_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn ct_skip_leading_char(s : String, target : Int) -> String {
  let mut idx = 0
  let len = s.length()
  while idx < len && ct_char_at(s, idx) == target {
    idx = idx + 1
  }
  ct_string_slice_from(s, idx)
}

///|
fn ct_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn ct_find_char(s : String, target : Int) -> Int? {
  let mut idx = 0
  while idx < s.length() {
    if ct_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn ct_string_slice(s : String, start : Int, end : Int) -> String {
  str_string_slice(s, start, end)
}

///|
fn ct_string_slice_from(s : String, start : Int) -> String {
  str_string_slice_from(s, start)
}
