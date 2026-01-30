///|
/// Helper functions

///|

///|

///|
fn au_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn au_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn au_string_slice(s : String, start : Int, end : Int) -> String {
  str_string_slice(s, start, end)
}

///|
fn au_string_slice_from(s : String, start : Int) -> String {
  str_string_slice_from(s, start)
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
  str_split_string(s, sep)
}

///|
fn au_to_lower_case(s : String) -> String {
  str_to_lower_case(s)
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
