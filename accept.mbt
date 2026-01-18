///|
/// Accept header parsing errors (RFC 9110 Section 12.5)
pub(all) enum AcceptError {
  Empty
  InvalidFormat
  InvalidMediaRange
  InvalidToken
  InvalidParameter
  InvalidQValue
  InvalidLanguageTag
} derive(Show, Eq)

///|
/// Q value (0.000 - 1.000)
pub(all) struct QValue {
  value : Int
} derive(Eq)

///|
pub fn QValue::parse(input : String) -> Result[QValue, AcceptError] {
  let s = acc_trim_string(input)
  if s.length() == 0 {
    return Err(InvalidQValue)
  }
  if s == "1" {
    return Ok({ value: 1000 })
  }
  if acc_string_starts_with(s, "1.") {
    let rest = acc_string_slice_from(s, 2)
    if rest.length() == 0 {
      return Ok({ value: 1000 })
    }
    // Must be all zeros
    let mut idx = 0
    while idx < rest.length() {
      if acc_char_at(rest, idx) != 48 { // not '0'
        return Err(InvalidQValue)
      }
      idx = idx + 1
    }
    return Ok({ value: 1000 })
  }
  if s == "0" {
    return Ok({ value: 0 })
  }
  if acc_string_starts_with(s, "0.") {
    let rest = acc_string_slice_from(s, 2)
    if rest.length() > 3 || rest.length() == 0 {
      return Err(InvalidQValue)
    }
    // Check all digits
    let mut idx = 0
    while idx < rest.length() {
      let ch = acc_char_at(rest, idx)
      if ch < 48 || ch > 57 { // not '0'-'9'
        return Err(InvalidQValue)
      }
      idx = idx + 1
    }
    // Calculate value
    let mut value = 0
    let mut idx = 0
    while idx < rest.length() {
      let digit = acc_char_at(rest, idx) - 48
      let multiplier = acc_int_pow(10, 2 - idx)
      value = value + digit * multiplier
      idx = idx + 1
    }
    return Ok({ value, })
  }
  Err(InvalidQValue)
}

///|
pub fn QValue::value(self : QValue) -> Int {
  self.value
}

///|
pub fn QValue::to_string(self : QValue) -> String {
  if self.value == 1000 {
    "1"
  } else if self.value == 0 {
    "0"
  } else {
    let frac = if self.value >= 100 {
      self.value.to_string()
    } else if self.value >= 10 {
      "0" + (self.value * 10).to_string()
    } else {
      "00" + self.value.to_string()
    }
    // Trim trailing zeros
    let mut trimmed = frac
    if acc_string_ends_with(trimmed, "0") {
      trimmed = acc_trim_trailing_zeros(trimmed)
    }
    if acc_string_ends_with(trimmed, "0") {
      trimmed = acc_trim_trailing_zeros(trimmed)
    }
    if acc_string_ends_with(trimmed, "0") {
      trimmed = acc_trim_trailing_zeros(trimmed)
    }
    "0." + trimmed
  }
}

///|
/// Accept header (RFC 9110 Section 12.5)
pub(all) struct Accept {
  items : Array[MediaRange]
} derive(Eq)

///|
pub fn Accept::parse(input : String) -> Result[Accept, AcceptError] {
  let s = acc_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = acc_split_with_quotes(s, 44) // ,
  let mut items : Array[MediaRange] = []
  let mut part_idx = 0
  while part_idx < parts.length() {
    let part = acc_trim_string(parts[part_idx])
    if part.length() > 0 {
      let parse_result = acc_parse_media_range_item(part)
      match parse_result {
        Ok(item) => {
          let new_items = []
          let mut idx = 0
          while idx < items.length() {
            new_items.push(items[idx])
            idx = idx + 1
          }
          new_items.push(item)
          items = new_items
        }
        Err(e) => return Err(e)
      }
    }
    part_idx = part_idx + 1
  }
  if items.length() == 0 {
    return Err(Empty)
  }
  Ok({ items, })
}

///|
pub fn Accept::items(self : Accept) -> Array[MediaRange] {
  self.items
}

///|
pub fn Accept::to_string(self : Accept) -> String {
  let strs = acc_map_items(self.items, fn(i) { i.to_string() })
  acc_join_strings(strs, ", ")
}

///|
/// Media range for Accept header
pub(all) struct MediaRange {
  media_type : String
  subtype : String
  parameters : Array[(String, String)]
  q : QValue
} derive(Eq)

///|
pub fn MediaRange::media_type(self : MediaRange) -> String {
  self.media_type
}

///|
pub fn MediaRange::subtype(self : MediaRange) -> String {
  self.subtype
}

///|
pub fn MediaRange::parameters(self : MediaRange) -> Array[(String, String)] {
  self.parameters
}

///|
pub fn MediaRange::qvalue(self : MediaRange) -> QValue {
  self.q
}

///|
pub fn MediaRange::to_string(self : MediaRange) -> String {
  let mut result = self.media_type + "/" + self.subtype
  let mut idx = 0
  while idx < self.parameters.length() {
    let (name, value) = self.parameters[idx]
    if acc_needs_quoting(value) {
      result = result + "; " + name + "=\"" + acc_escape_quotes(value) + "\""
    } else {
      result = result + "; " + name + "=" + value
    }
    idx = idx + 1
  }
  if self.q.value < 1000 {
    result = result + "; q=" + self.q.to_string()
  }
  result
}

///|
/// Accept-Charset header
pub(all) struct AcceptCharset {
  items : Array[CharsetRange]
} derive(Eq)

///|
pub fn AcceptCharset::parse(
  input : String,
) -> Result[AcceptCharset, AcceptError] {
  let parse_result = acc_parse_weighted_tokens(input, true, true)
  match parse_result {
    Err(e) => Err(e)
    Ok(pairs) => {
      let mut items : Array[CharsetRange] = []
      let mut idx = 0
      while idx < pairs.length() {
        let (value, q) = pairs[idx]
        let new_items = []
        let mut j = 0
        while j < items.length() {
          new_items.push(items[j])
          j = j + 1
        }
        new_items.push({ charset: value, q })
        items = new_items
        idx = idx + 1
      }
      Ok({ items, })
    }
  }
}

///|
pub fn AcceptCharset::items(self : AcceptCharset) -> Array[CharsetRange] {
  self.items
}

///|
/// Charset range for Accept-Charset
pub(all) struct CharsetRange {
  charset : String
  q : QValue
} derive(Eq)

///|
pub fn CharsetRange::charset(self : CharsetRange) -> String {
  self.charset
}

///|
pub fn CharsetRange::qvalue(self : CharsetRange) -> QValue {
  self.q
}

///|
pub fn CharsetRange::to_string(self : CharsetRange) -> String {
  if self.q.value < 1000 {
    self.charset + "; q=" + self.q.to_string()
  } else {
    self.charset
  }
}

///|
/// Accept-Encoding header
pub(all) struct AcceptEncoding {
  items : Array[EncodingRange]
} derive(Eq)

///|
pub fn AcceptEncoding::parse(
  input : String,
) -> Result[AcceptEncoding, AcceptError] {
  let parse_result = acc_parse_weighted_tokens(input, true, true)
  match parse_result {
    Err(e) => Err(e)
    Ok(pairs) => {
      let mut items : Array[EncodingRange] = []
      let mut idx = 0
      while idx < pairs.length() {
        let (value, q) = pairs[idx]
        let new_items = []
        let mut j = 0
        while j < items.length() {
          new_items.push(items[j])
          j = j + 1
        }
        new_items.push({ coding: value, q })
        items = new_items
        idx = idx + 1
      }
      Ok({ items, })
    }
  }
}

///|
pub fn AcceptEncoding::items(self : AcceptEncoding) -> Array[EncodingRange] {
  self.items
}

///|
/// Encoding range for Accept-Encoding
pub(all) struct EncodingRange {
  coding : String
  q : QValue
} derive(Eq)

///|
pub fn EncodingRange::coding(self : EncodingRange) -> String {
  self.coding
}

///|
pub fn EncodingRange::qvalue(self : EncodingRange) -> QValue {
  self.q
}

///|
pub fn EncodingRange::to_string(self : EncodingRange) -> String {
  if self.q.value < 1000 {
    self.coding + "; q=" + self.q.to_string()
  } else {
    self.coding
  }
}

///|
/// Accept-Language header
pub(all) struct AcceptLanguage {
  items : Array[LanguageRange]
} derive(Eq)

///|
pub fn AcceptLanguage::parse(
  input : String,
) -> Result[AcceptLanguage, AcceptError] {
  let parse_result = acc_parse_weighted_tokens_with_validator(
    input, false, true, acc_validate_language_range,
  )
  match parse_result {
    Err(e) => Err(e)
    Ok(pairs) => {
      let mut items : Array[LanguageRange] = []
      let mut idx = 0
      while idx < pairs.length() {
        let (value, q) = pairs[idx]
        let new_items = []
        let mut j = 0
        while j < items.length() {
          new_items.push(items[j])
          j = j + 1
        }
        new_items.push({ language: value, q })
        items = new_items
        idx = idx + 1
      }
      Ok({ items, })
    }
  }
}

///|
pub fn AcceptLanguage::items(self : AcceptLanguage) -> Array[LanguageRange] {
  self.items
}

///|
/// Language range for Accept-Language
pub(all) struct LanguageRange {
  language : String
  q : QValue
} derive(Eq)

///|
pub fn LanguageRange::language(self : LanguageRange) -> String {
  self.language
}

///|
pub fn LanguageRange::qvalue(self : LanguageRange) -> QValue {
  self.q
}

///|
pub fn LanguageRange::to_string(self : LanguageRange) -> String {
  if self.q.value < 1000 {
    self.language + "; q=" + self.q.to_string()
  } else {
    self.language
  }
}

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
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = acc_char_at(s, idx)
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
fn acc_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = acc_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = acc_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  acc_string_slice(s, start, end)
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
  if idx >= s.length() {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
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
fn acc_string_slice_from(s : String, start : Int) -> String {
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
  let result = []
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
      result.push(acc_string_slice(s, start, idx))
      start = idx + sep_len
      idx = start
    } else {
      idx = idx + 1
    }
  }
  result.push(acc_string_slice_from(s, start))
  result
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
