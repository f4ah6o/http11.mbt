///|
/// Content-Language header parsing errors (RFC 9110 Section 8.5)
pub(all) enum ContentLanguageError {
  Empty
  InvalidFormat
  InvalidLanguageTag
} derive(Show, Eq)

///|
/// Content-Language header (RFC 9110 Section 8.5)
pub(all) struct ContentLanguage {
  tags : Array[String]
} derive(Eq)

///|
pub fn ContentLanguage::parse(
  input : String,
) -> Result[ContentLanguage, ContentLanguageError] {
  let s = cl_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = cl_split_string(s, ",")
  let tags : Array[String] = []
  let mut part_idx = 0
  while part_idx < parts.length() {
    let tag = cl_trim_string(parts[part_idx])
    if tag.length() > 0 {
      if !cl_is_valid_language_tag(tag) {
        return Err(InvalidLanguageTag)
      }
      tags.push(tag)
    }
    part_idx = part_idx + 1
  }
  if tags.length() == 0 {
    return Err(Empty)
  }
  Ok({ tags, })
}

///|
pub fn ContentLanguage::tags(self : ContentLanguage) -> Array[String] {
  self.tags
}

///|
pub fn ContentLanguage::to_string(self : ContentLanguage) -> String {
  cl_join_strings(self.tags, ", ")
}

///|
/// Helper functions
///

///|
fn cl_is_valid_language_tag(tag : String) -> Bool {
  if tag.length() == 0 {
    return false
  }

  // Split by '-' and validate each part
  let parts = cl_split_string(tag, "-")
  let mut has_part = false
  let mut idx = 0
  while idx < parts.length() {
    let part = parts[idx]
    has_part = true
    if part.length() == 0 || part.length() > 8 {
      return false
    }
    // Check alphanumeric
    let mut ch_idx = 0
    while ch_idx < part.length() {
      let ch = cl_char_at(part, ch_idx)
      if !cl_is_alnum(ch) {
        return false
      }
      ch_idx = ch_idx + 1
    }
    idx = idx + 1
  }
  has_part
}

///|
fn cl_is_alnum(b : Int) -> Bool {
  (b >= 48 && b <= 57) || // 0-9
  (b >= 65 && b <= 90) || // A-Z
  (b >= 97 && b <= 122) // a-z
}

///|
fn cl_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn cl_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn cl_split_string(s : String, sep : String) -> Array[String] {
  str_split_string(s, sep)
}

///|
fn cl_join_strings(strs : Array[String], sep : String) -> String {
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
