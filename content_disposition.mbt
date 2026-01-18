///|
/// Content-Disposition header parsing errors (RFC 6266)
pub(all) enum ContentDispositionError {
  Empty
  InvalidFormat
  InvalidDispositionType
  InvalidParameter
  InvalidExtValue
} derive(Show, Eq)

///|
/// Disposition type
pub(all) enum DispositionType {
  Inline
  Attachment
  FormData
} derive(Eq)

///|
pub fn DispositionType::to_string(self : DispositionType) -> String {
  match self {
    Inline => "inline"
    Attachment => "attachment"
    FormData => "form-data"
  }
}

///|
/// Content-Disposition header (RFC 6266)
pub(all) struct ContentDisposition {
  disposition_type : DispositionType
  filename : String?
  filename_ext : String?
  name : String?
  parameters : Array[(String, String)]
} derive(Eq)

///|
pub fn ContentDisposition::parse(
  input : String,
) -> Result[ContentDisposition, ContentDispositionError] {
  let s = cd_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = cd_split_params(s)
  if parts.length() == 0 {
    return Err(InvalidFormat)
  }
  let type_str = cd_to_lower_case(cd_trim_string(parts[0]))
  let disp_type = cd_parse_disposition_type(type_str)
  match disp_type {
    Err(e) => return Err(e)
    Ok(dt) => {
      let mut cd = {
        disposition_type: dt,
        filename: None,
        filename_ext: None,
        name: None,
        parameters: [],
      }
      let mut part_idx = 1
      while part_idx < parts.length() {
        let part = cd_trim_string(parts[part_idx])
        if part.length() > 0 {
          let eq_pos = cd_find_char(part, 61) // =
          match eq_pos {
            Some(pos) => {
              let param_name = cd_to_lower_case(
                cd_trim_string(cd_string_slice(part, 0, pos)),
              )
              let param_value = cd_trim_string(
                cd_string_slice_from(part, pos + 1),
              )
              match param_name {
                "filename" => {
                  let parse_result = cd_parse_param_value(param_value)
                  match parse_result {
                    Ok(value) =>
                      cd = {
                        disposition_type: cd.disposition_type,
                        filename: Some(value),
                        filename_ext: cd.filename_ext,
                        name: cd.name,
                        parameters: cd.parameters,
                      }
                    Err(e) => return Err(e)
                  }
                }
                "filename*" => {
                  let parse_result = cd_parse_ext_value(param_value)
                  match parse_result {
                    Ok(value) =>
                      cd = {
                        disposition_type: cd.disposition_type,
                        filename: cd.filename,
                        filename_ext: Some(value),
                        name: cd.name,
                        parameters: cd.parameters,
                      }
                    Err(e) => return Err(e)
                  }
                }
                "name" => {
                  let parse_result = cd_parse_param_value(param_value)
                  match parse_result {
                    Ok(value) =>
                      cd = {
                        disposition_type: cd.disposition_type,
                        filename: cd.filename,
                        filename_ext: cd.filename_ext,
                        name: Some(value),
                        parameters: cd.parameters,
                      }
                    Err(e) => return Err(e)
                  }
                }
                _ => {
                  let parse_result = cd_parse_param_value(param_value)
                  match parse_result {
                    Ok(value) => {
                      let new_params = []
                      let mut j = 0
                      while j < cd.parameters.length() {
                        new_params.push(cd.parameters[j])
                        j = j + 1
                      }
                      new_params.push((param_name, value))
                      cd = {
                        disposition_type: cd.disposition_type,
                        filename: cd.filename,
                        filename_ext: cd.filename_ext,
                        name: cd.name,
                        parameters: new_params,
                      }
                    }
                    Err(e) => return Err(e)
                  }
                }
              }
            }
            None => {
              let _ = ()

            }
          }
        }
        part_idx = part_idx + 1
      }
      Ok(cd)
    }
  }
}

///|
pub fn ContentDisposition::new(
  disposition_type : DispositionType,
) -> ContentDisposition {
  {
    disposition_type,
    filename: None,
    filename_ext: None,
    name: None,
    parameters: [],
  }
}

///|
pub fn ContentDisposition::disposition_type(
  self : ContentDisposition,
) -> DispositionType {
  self.disposition_type
}

///|
pub fn ContentDisposition::filename(self : ContentDisposition) -> String? {
  match self.filename_ext {
    Some(fe) => Some(fe)
    None => self.filename
  }
}

///|
pub fn ContentDisposition::filename_ascii(self : ContentDisposition) -> String? {
  self.filename
}

///|
pub fn ContentDisposition::filename_ext(self : ContentDisposition) -> String? {
  self.filename_ext
}

///|
pub fn ContentDisposition::name(self : ContentDisposition) -> String? {
  self.name
}

///|
pub fn ContentDisposition::parameter(
  self : ContentDisposition,
  name : String,
) -> String? {
  let name_lower = cd_to_lower_case(name)
  let mut idx = 0
  while idx < self.parameters.length() {
    let (k, v) = self.parameters[idx]
    if k == name_lower {
      return Some(v)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn ContentDisposition::is_inline(self : ContentDisposition) -> Bool {
  match self.disposition_type {
    Inline => true
    _ => false
  }
}

///|
pub fn ContentDisposition::is_attachment(self : ContentDisposition) -> Bool {
  match self.disposition_type {
    Attachment => true
    _ => false
  }
}

///|
pub fn ContentDisposition::is_form_data(self : ContentDisposition) -> Bool {
  match self.disposition_type {
    FormData => true
    _ => false
  }
}

///|
pub fn ContentDisposition::with_filename(
  self : ContentDisposition,
  filename : String,
) -> ContentDisposition {
  {
    disposition_type: self.disposition_type,
    filename: Some(filename),
    filename_ext: self.filename_ext,
    name: self.name,
    parameters: self.parameters,
  }
}

///|
pub fn ContentDisposition::with_filename_ext(
  self : ContentDisposition,
  filename_ext : String,
) -> ContentDisposition {
  {
    disposition_type: self.disposition_type,
    filename: self.filename,
    filename_ext: Some(filename_ext),
    name: self.name,
    parameters: self.parameters,
  }
}

///|
pub fn ContentDisposition::with_name(
  self : ContentDisposition,
  name : String,
) -> ContentDisposition {
  {
    disposition_type: self.disposition_type,
    filename: self.filename,
    filename_ext: self.filename_ext,
    name: Some(name),
    parameters: self.parameters,
  }
}

///|
pub fn ContentDisposition::to_string(self : ContentDisposition) -> String {
  let mut result = self.disposition_type.to_string()
  match self.name {
    Some(n) => result = result + "; name=\"" + cd_escape_quoted_string(n) + "\""
    None => {
      let _ = ()

    }
  }
  match self.filename {
    Some(f) =>
      result = result + "; filename=\"" + cd_escape_quoted_string(f) + "\""
    None => {
      let _ = ()

    }
  }
  match self.filename_ext {
    Some(fe) =>
      result = result + "; filename*=UTF-8''" + cd_encode_ext_value(fe)
    None => {
      let _ = ()

    }
  }
  let mut idx = 0
  while idx < self.parameters.length() {
    let (name, value) = self.parameters[idx]
    result = result +
      "; " +
      name +
      "=\"" +
      cd_escape_quoted_string(value) +
      "\""
    idx = idx + 1
  }
  result
}

///|
/// Helper functions
///

///|
fn cd_parse_disposition_type(
  s : String,
) -> Result[DispositionType, ContentDispositionError] {
  match s {
    "inline" => Ok(Inline)
    "attachment" => Ok(Attachment)
    "form-data" => Ok(FormData)
    _ => Err(InvalidDispositionType)
  }
}

///|
fn cd_split_params(input : String) -> Array[String] {
  let mut result : Array[String] = []
  let mut current = ""
  let mut in_quotes = false
  let mut escape_next = false
  let mut idx = 0
  let len = input.length()
  while idx < len {
    let ch = cd_char_at(input, idx)
    if escape_next {
      current = current + Int::unsafe_to_char(ch).to_string()
      escape_next = false
      idx = idx + 1
    } else if ch == 92 && in_quotes { // \
      current = current + "\\"
      escape_next = true
      idx = idx + 1
    } else if ch == 34 { // "
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
fn cd_parse_param_value(
  value : String,
) -> Result[String, ContentDispositionError] {
  let s = cd_trim_string(value)
  if s.length() > 0 && cd_char_at(s, 0) == 34 { // "
    if s.length() >= 2 && cd_char_at(s, s.length() - 1) == 34 {
      cd_parse_quoted_string(cd_string_slice(s, 1, s.length() - 1))
    } else {
      Err(InvalidParameter)
    }
  } else {
    Ok(s)
  }
}

///|
fn cd_parse_quoted_string(
  s : String,
) -> Result[String, ContentDispositionError] {
  let mut result = ""
  let mut idx = 0
  let len = s.length()
  while idx < len {
    let ch = cd_char_at(s, idx)
    if ch == 92 { // \
      if idx + 1 < len {
        result = result +
          Int::unsafe_to_char(cd_char_at(s, idx + 1)).to_string()
        idx = idx + 2
      } else {
        return Err(InvalidParameter)
      }
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
      idx = idx + 1
    }
  }
  Ok(result)
}

///|
fn cd_parse_ext_value(
  value : String,
) -> Result[String, ContentDispositionError] {
  let s = cd_trim_string(value)

  // Find first '
  let first_quote = cd_find_char(s, 39) // '
  match first_quote {
    None => return Err(InvalidExtValue)
    Some(pos) => {
      let charset = cd_string_slice(s, 0, pos)
      let rest = cd_string_slice_from(s, pos + 1)

      // Find second '
      let second_quote = cd_find_char(rest, 39)
      match second_quote {
        None => return Err(InvalidExtValue)
        Some(pos2) => {
          // language is ignored
          let encoded_value = cd_string_slice_from(rest, pos2 + 1)

          // Only UTF-8 is supported
          if cd_to_upper_case(charset) != "UTF-8" {
            return Err(InvalidExtValue)
          }
          cd_percent_decode(encoded_value)
        }
      }
    }
  }
}

///|
fn cd_percent_decode(s : String) -> Result[String, ContentDispositionError] {
  let mut bytes : Array[Int] = []
  let mut idx = 0
  let len = s.length()
  while idx < len {
    let ch = cd_char_at(s, idx)
    if ch == 37 { // %
      if idx + 2 < len {
        let hex = cd_string_slice(s, idx + 1, idx + 3)
        let byte_result = cd_parse_hex(hex)
        match byte_result {
          Ok(byte) => {
            let new_bytes = []
            let mut j = 0
            while j < bytes.length() {
              new_bytes.push(bytes[j])
              j = j + 1
            }
            new_bytes.push(byte)
            bytes = new_bytes
            idx = idx + 3
          }
          Err(_) => return Err(InvalidExtValue)
        }
      } else {
        return Err(InvalidExtValue)
      }
    } else {
      let new_bytes = []
      let mut j = 0
      while j < bytes.length() {
        new_bytes.push(bytes[j])
        j = j + 1
      }
      new_bytes.push(ch)
      bytes = new_bytes
      idx = idx + 1
    }
  }
  cd_utf8_from_bytes(bytes)
}

///|
fn cd_utf8_from_bytes(
  bytes : Array[Int],
) -> Result[String, ContentDispositionError] {
  let mut result = ""
  let mut idx = 0
  while idx < bytes.length() {
    let b = bytes[idx]
    if b < 128 {
      // ASCII
      result = result + Int::unsafe_to_char(b).to_string()
      idx = idx + 1
    } else if b >= 192 && b < 224 {
      // 2-byte sequence
      if idx + 1 < bytes.length() {
        let b2 = bytes[idx + 1]
        if b2 >= 128 && b2 < 192 {
          let code = (b - 192) * 64 + (b2 - 128)
          result = result + Int::unsafe_to_char(code).to_string()
          idx = idx + 2
        } else {
          return Err(InvalidExtValue)
        }
      } else {
        return Err(InvalidExtValue)
      }
    } else if b >= 224 && b < 240 {
      // 3-byte sequence
      if idx + 2 < bytes.length() {
        let b2 = bytes[idx + 1]
        let b3 = bytes[idx + 2]
        if b2 >= 128 && b2 < 192 && b3 >= 128 && b3 < 192 {
          let code = (b - 224) * 4096 + (b2 - 128) * 64 + (b3 - 128)
          result = result + Int::unsafe_to_char(code).to_string()
          idx = idx + 3
        } else {
          return Err(InvalidExtValue)
        }
      } else {
        return Err(InvalidExtValue)
      }
    } else if b >= 240 && b < 248 {
      // 4-byte sequence
      if idx + 3 < bytes.length() {
        let b2 = bytes[idx + 1]
        let b3 = bytes[idx + 2]
        let b4 = bytes[idx + 3]
        if b2 >= 128 &&
          b2 < 192 &&
          b3 >= 128 &&
          b3 < 192 &&
          b4 >= 128 &&
          b4 < 192 {
          let code = (b - 240) * 262144 +
            (b2 - 128) * 4096 +
            (b3 - 128) * 64 +
            (b4 - 128)
          result = result + Int::unsafe_to_char(code).to_string()
          idx = idx + 4
        } else {
          return Err(InvalidExtValue)
        }
      } else {
        return Err(InvalidExtValue)
      }
    } else {
      return Err(InvalidExtValue)
    }
  }
  Ok(result)
}

///|
fn cd_parse_hex(s : String) -> Result[Int, ContentDispositionError] {
  let mut result = 0
  let mut idx = 0
  while idx < s.length() {
    let ch = cd_char_at(s, idx)
    let digit = if ch >= 48 && ch <= 57 { // 0-9
      ch - 48
    } else if ch >= 65 && ch <= 70 { // A-F
      ch - 55
    } else if ch >= 97 && ch <= 102 { // a-f
      ch - 87
    } else {
      return Err(InvalidExtValue)
    }
    result = result * 16 + digit
    idx = idx + 1
  }
  Ok(result)
}

///|
fn cd_encode_ext_value(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = cd_char_at(s, idx)
    if cd_is_attr_char(ch) {
      result = result + Int::unsafe_to_char(ch).to_string()
    } else {
      result = result + "%" + cd_int_to_hex(ch, 2)
    }
    idx = idx + 1
  }
  result
}

///|
fn cd_is_attr_char(b : Int) -> Bool {
  (b >= 65 && b <= 90) || // A-Z
  (b >= 97 && b <= 122) || // a-z
  (b >= 48 && b <= 57) || // 0-9
  b == 33 ||
  b == 35 ||
  b == 36 ||
  b == 38 ||
  b == 43 ||
  b == 45 ||
  b == 46 ||
  b == 94 ||
  b == 95 ||
  b == 96 ||
  b == 124 ||
  b == 126
}

///|
fn cd_escape_quoted_string(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = cd_char_at(s, idx)
    if ch == 34 || ch == 92 { // " or \
      result = result + "\\"
    }
    result = result + Int::unsafe_to_char(ch).to_string()
    idx = idx + 1
  }
  result
}

///|
fn cd_int_to_hex(n : Int, padding : Int) -> String {
  let chars = "0123456789ABCDEF"
  let mut result = ""
  let mut val = n
  let mut len = 0
  while val > 0 {
    let digit = val % 16
    result = Int::unsafe_to_char(cd_char_at(chars, digit)).to_string() + result
    val = val / 16
    len = len + 1
  }
  while len < padding {
    result = "0" + result
    len = len + 1
  }
  if result == "" {
    "00"
  } else {
    result
  }
}

///|
fn cd_to_upper_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = cd_char_at(s, idx)
    if ch >= 97 && ch <= 122 { // a-z
      result = result + Int::unsafe_to_char(ch - 32).to_string()
    } else {
      result = result + Int::unsafe_to_char(ch).to_string()
    }
    idx = idx + 1
  }
  result
}

///|
fn cd_to_lower_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = cd_char_at(s, idx)
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
fn cd_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = cd_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = cd_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  cd_string_slice(s, start, end)
}

///|
fn cd_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
}

///|
fn cd_find_char(s : String, target : Int) -> Int? {
  let mut idx = 0
  while idx < s.length() {
    if cd_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn cd_string_slice(s : String, start : Int, end : Int) -> String {
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
fn cd_string_slice_from(s : String, start : Int) -> String {
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
