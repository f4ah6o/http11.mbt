///|
/// Helper functions
///

///|
fn acc_parse_media_range_item(
  input : String,
) -> Result[MediaRange, AcceptError] {
  let parts = acc_split_with_quotes(input, 59) // ;
  if parts.length() == 0 {
    return Err(InvalidMediaRange)
  }
  let media = acc_trim_string(parts[0])
  let parse_result = acc_parse_media_range(media)
  match parse_result {
    Err(e) => return Err(e)
    Ok((mt, st)) => {
      let mut params : Array[(String, String)] = []
      let mut qvalue = { value: 1000 }
      let mut q_seen = false
      let mut param_idx = 1
      while param_idx < parts.length() {
        let param = acc_trim_string(parts[param_idx])
        if param.length() > 0 {
          let eq_pos = acc_find_char(param, 61) // =
          match eq_pos {
            None => return Err(InvalidParameter)
            Some(pos) => {
              let name = acc_to_lower_case(
                acc_trim_string(acc_string_slice(param, 0, pos)),
              )
              let value_str = acc_trim_string(
                acc_string_slice_from(param, pos + 1),
              )
              if name == "q" {
                if q_seen {
                  return Err(InvalidQValue)
                }
                let q_result = QValue::parse(value_str)
                match q_result {
                  Ok(q) => {
                    qvalue = q
                    q_seen = true
                  }
                  Err(e) => return Err(e)
                }
              } else {
                let value_result = acc_parse_param_value(value_str)
                match value_result {
                  Ok(value) => {
                    let new_params = []
                    let mut j = 0
                    while j < params.length() {
                      new_params.push(params[j])
                      j = j + 1
                    }
                    new_params.push((name, value))
                    params = new_params
                  }
                  Err(e) => return Err(e)
                }
              }
            }
          }
        }
        param_idx = param_idx + 1
      }
      Ok({ media_type: mt, subtype: st, parameters: params, q: qvalue })
    }
  }
}

///|
fn acc_parse_media_range(
  input : String,
) -> Result[(String, String), AcceptError] {
  let s = acc_trim_string(input)
  if s == "*/*" {
    return Ok(("*", "*"))
  }
  let slash_pos = acc_find_char(s, 47) // /
  match slash_pos {
    None => return Err(InvalidMediaRange)
    Some(pos) => {
      let mt = acc_trim_string(acc_string_slice(s, 0, pos))
      let st = acc_trim_string(acc_string_slice_from(s, pos + 1))
      if mt == "*" {
        if st != "*" {
          return Err(InvalidMediaRange)
        }
        return Ok(("*", "*"))
      }
      if st == "*" {
        if !acc_is_valid_token(mt) {
          return Err(InvalidMediaRange)
        }
        return Ok((acc_to_lower_case(mt), "*"))
      }
      if !acc_is_valid_token(mt) || !acc_is_valid_token(st) {
        return Err(InvalidMediaRange)
      }
      Ok((acc_to_lower_case(mt), acc_to_lower_case(st)))
    }
  }
}

///|
type WeightedToken = (String, QValue)

///|
fn acc_parse_weighted_tokens(
  input : String,
  lowercase : Bool,
  allow_wildcard : Bool,
) -> Result[Array[WeightedToken], AcceptError] {
  acc_parse_weighted_tokens_with_validator(
    input, lowercase, allow_wildcard, acc_validate_token_or_star,
  )
}

///|
fn acc_parse_weighted_tokens_with_validator(
  input : String,
  lowercase : Bool,
  allow_wildcard : Bool,
  validator : (String) -> Bool,
) -> Result[Array[WeightedToken], AcceptError] {
  let s = acc_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = acc_split_with_quotes(s, 44) // ,
  let mut items : Array[WeightedToken] = []
  let mut part_idx = 0
  while part_idx < parts.length() {
    let part = acc_trim_string(parts[part_idx])
    if part.length() > 0 {
      let subparts = acc_split_with_quotes(part, 59) // ;
      if subparts.length() == 0 {
        return Err(InvalidFormat)
      }
      let token = acc_trim_string(subparts[0])
      if token.length() == 0 {
        return Err(InvalidFormat)
      }
      if token == "*" && !allow_wildcard {
        return Err(InvalidFormat)
      }
      if token != "*" && !validator(token) {
        return Err(InvalidToken)
      }
      let mut qvalue = { value: 1000 }
      let mut q_seen = false
      let mut sub_idx = 1
      while sub_idx < subparts.length() {
        let param = acc_trim_string(subparts[sub_idx])
        if param.length() > 0 {
          let eq_pos = acc_find_char(param, 61) // =
          match eq_pos {
            Some(pos) => {
              let name = acc_trim_string(acc_string_slice(param, 0, pos))
              if acc_to_lower_case(name) == "q" {
                if q_seen {
                  return Err(InvalidQValue)
                }
                let value = acc_trim_string(
                  acc_string_slice_from(param, pos + 1),
                )
                let q_result = QValue::parse(value)
                match q_result {
                  Ok(q) => {
                    qvalue = q
                    q_seen = true
                  }
                  Err(e) => return Err(e)
                }
              } else {
                return Err(InvalidParameter)
              }
            }
            None => {
              let _ = ()

            }
          }
        }
        sub_idx = sub_idx + 1
      }
      let token_value = if lowercase && token != "*" {
        acc_to_lower_case(token)
      } else {
        token
      }
      let new_items = []
      let mut idx = 0
      while idx < items.length() {
        new_items.push(items[idx])
        idx = idx + 1
      }
      new_items.push((token_value, qvalue))
      items = new_items
    }
    part_idx = part_idx + 1
  }
  if items.length() == 0 {
    return Err(Empty)
  }
  Ok(items)
}

///|
fn acc_parse_param_value(input : String) -> Result[String, AcceptError] {
  let s = acc_trim_string(input)
  if s.length() > 0 && acc_char_at(s, 0) == 34 { // "
    let after_quote = acc_string_slice_from(s, 1)
    let parse_result = acc_parse_quoted_string(after_quote)
    match parse_result {
      Ok((value, remaining)) => {
        let rest = acc_trim_string(remaining)
        if rest.length() != 0 {
          return Err(InvalidParameter)
        }
        Ok(value)
      }
      Err(e) => Err(e)
    }
  } else {
    if !acc_is_valid_token(s) {
      return Err(InvalidToken)
    }
    Ok(s)
  }
}

///|
fn acc_parse_quoted_string(
  input : String,
) -> Result[(String, String), AcceptError] {
  let mut result = ""
  let mut escaped = false
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let ch = acc_char_at(input, idx)
    if escaped {
      result = result + Int::unsafe_to_char(ch).to_string()
      escaped = false
      idx = idx + 1
    } else if ch == 92 { // \
      escaped = true
      idx = idx + 1
    } else if ch == 34 { // "
      return Ok((result, acc_string_slice_from(input, idx + 1)))
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
      idx = idx + 1
    }
  }
  Err(InvalidParameter)
}

///|
fn acc_validate_token_or_star(token : String) -> Bool {
  if token == "*" {
    return true
  }
  acc_is_valid_token(token)
}

///|
fn acc_validate_language_range(token : String) -> Bool {
  if token == "*" {
    return true
  }
  acc_is_valid_language_tag(token)
}

///|
fn acc_is_valid_language_tag(tag : String) -> Bool {
  if tag.length() == 0 {
    return false
  }
  let parts = acc_split_string(tag, "-")
  let mut idx = 0
  while idx < parts.length() {
    let part = parts[idx]
    if part.length() == 0 || part.length() > 8 {
      return false
    }
    let mut ch_idx = 0
    while ch_idx < part.length() {
      let ch = acc_char_at(part, ch_idx)
      if !acc_is_alnum(ch) {
        return false
      }
      ch_idx = ch_idx + 1
    }
    idx = idx + 1
  }
  true
}

///|
fn acc_is_valid_token(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut idx = 0
  while idx < s.length() {
    if !acc_is_token_char(acc_char_at(s, idx)) {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn acc_is_token_char(b : Int) -> Bool {
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
fn acc_is_alnum(b : Int) -> Bool {
  (b >= 48 && b <= 57) || // 0-9
  (b >= 65 && b <= 90) || // A-Z
  (b >= 97 && b <= 122) // a-z
}

///|
fn acc_needs_quoting(s : String) -> Bool {
  let mut idx = 0
  while idx < s.length() {
    if !acc_is_token_char(acc_char_at(s, idx)) {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
fn acc_escape_quotes(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = acc_char_at(s, idx)
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
fn acc_to_lower_case(s : String) -> String {
  str_to_lower_case(s)
}

///|
fn acc_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn acc_trim_trailing_zeros(s : String) -> String {
  let len = s.length()
  if len > 0 && acc_char_at(s, len - 1) == 48 { // '0'
    acc_string_slice(s, 0, len - 1)
  } else {
    s
  }
}

///|
fn acc_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn acc_find_char(s : String, target : Int) -> Int? {
  let mut idx = 0
  while idx < s.length() {
    if acc_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn acc_string_slice(s : String, start : Int, end : Int) -> String {
  str_string_slice(s, start, end)
}

///|
fn acc_string_slice_from(s : String, start : Int) -> String {
  str_string_slice_from(s, start)
}

///|
fn acc_string_starts_with(s : String, prefix : String) -> Bool {
  if prefix.length() > s.length() {
    return false
  }
  let mut idx = 0
  while idx < prefix.length() {
    if s[idx] != prefix[idx] {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn acc_string_ends_with(s : String, suffix : String) -> Bool {
  if suffix.length() > s.length() {
    return false
  }
  let s_len = s.length()
  let suffix_len = suffix.length()
  let mut idx = 0
  while idx < suffix_len {
    if s[s_len - suffix_len + idx] != suffix[idx] {
      return false
    }
    idx = idx + 1
  }
  true
}

///|
fn acc_split_string(s : String, sep : String) -> Array[String] {
  str_split_string(s, sep)
}

///|
fn acc_split_with_quotes(input : String, delimiter : Int) -> Array[String] {
  let result : Array[String] = []
  let mut start = 0
  let mut in_quote = false
  let mut escaped = false
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let ch = acc_char_at(input, idx)
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
      result.push(acc_string_slice(input, start, idx))
      start = idx + 1
    }
    idx = idx + 1
  }
  result.push(acc_string_slice_from(input, start))
  result
}

///|
fn[T, U] acc_map_items(arr : Array[T], f : (T) -> U) -> Array[U] {
  let result : Array[U] = []
  let mut idx = 0
  while idx < arr.length() {
    result.push(f(arr[idx]))
    idx = idx + 1
  }
  result
}

///|
fn acc_join_strings(strs : Array[String], sep : String) -> String {
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

///|
fn acc_int_pow(base : Int, exp : Int) -> Int {
  let mut result = 1
  let mut idx = 0
  while idx < exp {
    result = result * base
    idx = idx + 1
  }
  result
}
