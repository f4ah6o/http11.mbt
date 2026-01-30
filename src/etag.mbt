///|
/// ETag parsing errors
pub(all) enum ETagError {
  Empty
  InvalidFormat
  MissingQuote
  InvalidCharacter
} derive(Show, Eq)

///|
/// Entity Tag (ETag) (RFC 9110 Section 8.8.3)
pub(all) struct EntityTag {
  weak : Bool
  tag : String
} derive(Show, Eq)

///|
pub fn EntityTag::parse(input : String) -> Result[EntityTag, ETagError] {
  let s = etag_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let (weak, start_idx) = if s.length() >= 2 &&
    (etag_string_starts_with(s, "W/") || etag_string_starts_with(s, "w/")) {
    (true, 2)
  } else {
    (false, 0)
  }

  // Check for opening quote (ASCII 34 = ")
  if start_idx >= s.length() || etag_char_at(s, start_idx) != 34 {
    return Err(MissingQuote)
  }

  // Find closing quote
  let end_quote = etag_find_char_from(s, 34, start_idx + 1)
  match end_quote {
    None => Err(MissingQuote)
    Some(idx) => {
      let tag = etag_string_slice(s, start_idx + 1, idx)
      // Validate tag characters (etagc: 0x21 (!) or 0x23-0x7E or >= 0x80)
      if !is_valid_etag(tag) {
        return Err(InvalidCharacter)
      }
      Ok({ weak, tag })
    }
  }
}

///|
pub fn EntityTag::strong(tag : String) -> Result[EntityTag, ETagError] {
  if !is_valid_etag(tag) {
    return Err(InvalidCharacter)
  }
  Ok({ weak: false, tag })
}

///|
pub fn EntityTag::weak(tag : String) -> Result[EntityTag, ETagError] {
  if !is_valid_etag(tag) {
    return Err(InvalidCharacter)
  }
  Ok({ weak: true, tag })
}

///|
pub fn EntityTag::is_weak(self : EntityTag) -> Bool {
  self.weak
}

///|
pub fn EntityTag::is_strong(self : EntityTag) -> Bool {
  !self.weak
}

///|
pub fn EntityTag::tag(self : EntityTag) -> String {
  self.tag
}

///|
pub fn EntityTag::strong_compare(self : EntityTag, other : EntityTag) -> Bool {
  !self.weak && !other.weak && self.tag == other.tag
}

///|
pub fn EntityTag::weak_compare(self : EntityTag, other : EntityTag) -> Bool {
  self.tag == other.tag
}

///|
pub fn EntityTag::to_string(self : EntityTag) -> String {
  if self.weak {
    "W/\"" + self.tag + "\""
  } else {
    "\"" + self.tag + "\""
  }
}

///|
/// ETag list for If-Match, If-None-Match headers
pub(all) enum ETagList {
  Any
  Tags(Array[EntityTag])
} derive(Show, Eq)

///|
pub fn parse_etag_list(input : String) -> Result[ETagList, ETagError] {
  let s = etag_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  if s == "*" {
    return Ok(Any)
  }
  let parts = etag_split_string(s, ",")
  let etags : Array[EntityTag] = []
  let mut part_idx = 0
  while part_idx < parts.length() {
    let part = parts[part_idx]
    let trimmed = etag_trim_string(part)
    if trimmed.length() > 0 {
      let parse_result = EntityTag::parse(trimmed)
      match parse_result {
        Ok(etag) => etags.push(etag)
        Err(e) => return Err(e)
      }
    }
    part_idx = part_idx + 1
  }
  if etags.length() == 0 {
    return Err(Empty)
  }
  Ok(Tags(etags))
}

///|
pub fn ETagList::is_any(self : ETagList) -> Bool {
  match self {
    Any => true
    Tags(_) => false
  }
}

///|
pub fn ETagList::contains_weak(self : ETagList, etag : EntityTag) -> Bool {
  match self {
    Any => true
    Tags(tags) => {
      let mut idx = 0
      while idx < tags.length() {
        if tags[idx].weak_compare(etag) {
          return true
        }
        idx = idx + 1
      }
      false
    }
  }
}

///|
pub fn ETagList::contains_strong(self : ETagList, etag : EntityTag) -> Bool {
  match self {
    Any => true
    Tags(tags) => {
      let mut idx = 0
      while idx < tags.length() {
        if tags[idx].strong_compare(etag) {
          return true
        }
        idx = idx + 1
      }
      false
    }
  }
}

///|
pub fn ETagList::to_string(self : ETagList) -> String {
  match self {
    Any => "*"
    Tags(tags) => {
      let strs = array_map(tags, fn(t) { t.to_string() })
      etag_join_strings(strs, ", ")
    }
  }
}

///|

///|
/// Helper functions

///|

///|
fn is_valid_etag(tag : String) -> Bool {
  let mut idx = 0
  while idx < tag.length() {
    let ci = etag_char_at(tag, idx)
    // Check if character is valid etagc: 0x21 (!), 0x23-0x7E, or >= 0x80
    if ci == 33 || (ci >= 35 && ci <= 126) || ci >= 128 {
      idx = idx + 1
    } else {
      return false
    }
  }
  true
}

///|
fn etag_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn etag_string_starts_with(s : String, prefix : String) -> Bool {
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
fn etag_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn etag_find_char_from(s : String, target : Int, start : Int) -> Int? {
  let mut idx = start
  while idx < s.length() {
    if etag_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn etag_string_slice(s : String, start : Int, end : Int) -> String {
  str_string_slice(s, start, end)
}

///|
fn etag_split_string(s : String, sep : String) -> Array[String] {
  str_split_string(s, sep)
}

///|
fn[T, U] array_map(arr : Array[T], f : (T) -> U) -> Array[U] {
  let result : Array[U] = []
  let mut idx = 0
  while idx < arr.length() {
    let mapped = f(arr[idx])
    result.push(mapped)
    idx = idx + 1
  }
  result
}

///|
fn etag_join_strings(strs : Array[String], sep : String) -> String {
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
