///|
/// Range header parsing errors (RFC 9110)
pub(all) enum RangeError {
  Empty
  InvalidFormat
  InvalidUnit
  InvalidRange
  InvalidBounds
} derive(Show, Eq)

///|
/// Range specification (RFC 9110 Section 14.2)
pub(all) enum RangeSpec {
  /// Range from start to end (inclusive)
  /// bytes=0-499 -> Range { start: 0UL, end: 499UL }
  Range(UInt64, UInt64)
  /// Range from start to end of resource
  /// bytes=500- -> FromStart { start: 500UL }
  FromStart(UInt64)
  /// Last n bytes
  /// bytes=-500 -> Suffix { length: 500UL }
  Suffix(UInt64)
} derive(Eq)

///|
pub fn RangeSpec::to_bounds(
  self : RangeSpec,
  total_length : UInt64,
) -> (UInt64, UInt64)? {
  if total_length == 0UL {
    return None
  }
  match self {
    Range(s, e) => {
      if s > e || s >= total_length {
        return None
      }
      let end = if e < total_length { e } else { total_length - 1UL }
      Some((s, end))
    }
    FromStart(s) => {
      if s >= total_length {
        return None
      }
      Some((s, total_length - 1UL))
    }
    Suffix(l) => {
      if l == 0UL {
        return None
      }
      let start = if total_length > l { total_length - l } else { 0UL }
      Some((start, total_length - 1UL))
    }
  }
}

///|
pub fn RangeSpec::to_string(self : RangeSpec) -> String {
  match self {
    Range(s, e) => rg_u64_to_string(s) + "-" + rg_u64_to_string(e)
    FromStart(s) => rg_u64_to_string(s) + "-"
    Suffix(l) => "-" + rg_u64_to_string(l)
  }
}

///|
/// Range header (RFC 9110 Section 14.2)
pub(all) struct Range {
  unit : String
  ranges : Array[RangeSpec]
} derive(Eq)

///|
pub fn Range::parse(input : String) -> Result[Range, RangeError] {
  let s = input
  if s.length() == 0 {
    return Err(Empty)
  }

  // Check for "bytes=" prefix
  if s.length() < 6 {
    return Err(InvalidFormat)
  }

  // Simple check: does string start with "bytes="
  let mut has_bytes = true
  if s[0] != 'b' {
    has_bytes = false
  } else if s[1] != 'y' {
    has_bytes = false
  } else if s[2] != 't' {
    has_bytes = false
  } else if s[3] != 'e' {
    has_bytes = false
  } else if s[4] != 's' {
    has_bytes = false
  } else if s[5] != '=' {
    has_bytes = false
  }
  if !has_bytes {
    return Err(InvalidFormat)
  }

  // Parse everything after "bytes="
  let ranges_str = rg_string_slice_from(s, 6)
  let parts = rg_split_string(ranges_str, ",")
  let ranges : Array[RangeSpec] = []
  let mut idx = 0
  while idx < parts.length() {
    let part = rg_trim_string(parts[idx])
    if part.length() > 0 {
      match rg_parse_range_spec(part) {
        Ok(spec) => ranges.push(spec)
        Err(e) => return Err(e)
      }
    }
    idx = idx + 1
  }
  if ranges.length() == 0 {
    return Err(Empty)
  }
  Ok({ unit: "bytes", ranges })
}

///|
pub fn Range::unit(self : Range) -> String {
  self.unit
}

///|
pub fn Range::is_bytes(self : Range) -> Bool {
  rg_to_lower_case(self.unit) == "bytes"
}

///|
pub fn Range::ranges(self : Range) -> Array[RangeSpec] {
  self.ranges
}

///|
pub fn Range::first(self : Range) -> RangeSpec? {
  if self.ranges.length() > 0 {
    Some(self.ranges[0])
  } else {
    None
  }
}

///|
pub fn Range::to_string(self : Range) -> String {
  let mut result = self.unit + "="
  let mut idx = 0
  while idx < self.ranges.length() {
    if idx > 0 {
      result = result + ", "
    }
    result = result + self.ranges[idx].to_string()
    idx = idx + 1
  }
  result
}

///|
/// Content-Range header (RFC 9110 Section 14.4)
pub(all) struct ContentRange {
  unit : String
  start : UInt64?
  end : UInt64?
  complete_length : UInt64?
} derive(Eq)

///|
pub fn ContentRange::parse(input : String) -> Result[ContentRange, RangeError] {
  let s = rg_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  // Find space for "unit range/length" format
  let space_pos = rg_find_char(s, 32)
  match space_pos {
    None => Err(InvalidFormat)
    Some(pos) => {
      let unit = rg_trim_string(rg_string_slice(s, 0, pos))
      let rest = rg_trim_string(rg_string_slice_from(s, pos + 1))
      if unit.length() == 0 {
        return Err(InvalidUnit)
      }

      // Find '/' for "range/length"
      let slash_pos = rg_find_char(rest, 47)
      match slash_pos {
        None => Err(InvalidFormat)
        Some(spos) => {
          let range_str = rg_trim_string(rg_string_slice(rest, 0, spos))
          let length_str = rg_trim_string(rg_string_slice_from(rest, spos + 1))
          let complete_length : UInt64? = if length_str == "*" {
            None
          } else {
            match rg_parse_u64(length_str) {
              Some(len) => Some(len)
              None => return Err(InvalidFormat)
            }
          }
          if range_str == "*" {
            // unsatisfied range: bytes */1000
            return Ok({ unit, start: None, end: None, complete_length })
          }

          // Parse start-end
          let dash_pos = rg_find_char(range_str, 45)
          match dash_pos {
            None => Err(InvalidFormat)
            Some(dpos) => {
              let start_str = rg_string_slice(range_str, 0, dpos)
              let end_str = rg_string_slice_from(range_str, dpos + 1)
              match (rg_parse_u64(start_str), rg_parse_u64(end_str)) {
                (Some(s), Some(e)) => {
                  if s > e {
                    return Err(InvalidBounds)
                  }
                  Ok({ unit, start: Some(s), end: Some(e), complete_length })
                }
                _ => Err(InvalidFormat)
              }
            }
          }
        }
      }
    }
  }
}

///|
pub fn ContentRange::new_bytes(
  start : UInt64,
  end : UInt64,
  complete_length : UInt64?,
) -> ContentRange {
  { unit: "bytes", start: Some(start), end: Some(end), complete_length }
}

///|
pub fn ContentRange::unsatisfied(
  unit : String,
  complete_length : UInt64,
) -> ContentRange {
  { unit, start: None, end: None, complete_length: Some(complete_length) }
}

///|
pub fn ContentRange::unit(self : ContentRange) -> String {
  self.unit
}

///|
pub fn ContentRange::start(self : ContentRange) -> UInt64? {
  self.start
}

///|
pub fn ContentRange::end(self : ContentRange) -> UInt64? {
  self.end
}

///|
pub fn ContentRange::complete_length(self : ContentRange) -> UInt64? {
  self.complete_length
}

///|
pub fn ContentRange::length(self : ContentRange) -> UInt64? {
  match (self.start, self.end) {
    (Some(s), Some(e)) => if e >= s { Some(e - s + 1UL) } else { None }
    _ => None
  }
}

///|
pub fn ContentRange::is_unsatisfied(self : ContentRange) -> Bool {
  match (self.start, self.end) {
    (None, None) => true
    _ => false
  }
}

///|
pub fn ContentRange::to_string(self : ContentRange) -> String {
  let mut result = self.unit + " "
  match (self.start, self.end) {
    (Some(s), Some(e)) =>
      result = result + rg_u64_to_string(s) + "-" + rg_u64_to_string(e) + "/"
    _ => result = result + "*/"
  }
  match self.complete_length {
    Some(len) => result + rg_u64_to_string(len)
    None => result + "*"
  }
}

///|
/// Accept-Ranges header (RFC 9110 Section 14.3)
pub(all) struct AcceptRanges {
  units : Array[String]
} derive(Eq)

///|
pub fn AcceptRanges::parse(input : String) -> Result[AcceptRanges, RangeError] {
  let s = rg_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = rg_split_string(s, ",")
  let units : Array[String] = []
  let mut idx = 0
  while idx < parts.length() {
    let unit = rg_trim_string(parts[idx])
    if unit.length() > 0 {
      units.push(unit)
    }
    idx = idx + 1
  }
  if units.length() == 0 {
    return Err(Empty)
  }
  Ok({ units, })
}

///|
pub fn AcceptRanges::bytes() -> AcceptRanges {
  { units: ["bytes"] }
}

///|
pub fn AcceptRanges::none() -> AcceptRanges {
  { units: ["none"] }
}

///|
pub fn AcceptRanges::units(self : AcceptRanges) -> Array[String] {
  self.units
}

///|
pub fn AcceptRanges::accepts_bytes(self : AcceptRanges) -> Bool {
  let mut idx = 0
  while idx < self.units.length() {
    if rg_to_lower_case(self.units[idx]) == "bytes" {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
pub fn AcceptRanges::is_none(self : AcceptRanges) -> Bool {
  if self.units.length() == 1 && rg_to_lower_case(self.units[0]) == "none" {
    true
  } else {
    false
  }
}

///|
pub fn AcceptRanges::to_string(self : AcceptRanges) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < self.units.length() {
    if idx > 0 {
      result = result + ", "
    }
    result = result + self.units[idx]
    idx = idx + 1
  }
  result
}

///|

///|
/// Helper functions

///|

///|

///|
fn rg_parse_range_spec(s : String) -> Result[RangeSpec, RangeError] {
  // Find '-' manually by checking each character
  let mut dash_pos = -1
  let mut idx = 0
  while idx < s.length() {
    let ch_code = s[idx].to_int()
    if ch_code == 45 { // '-' = 45
      dash_pos = idx
      break
    }
    idx = idx + 1
  }
  if dash_pos == -1 {
    return Err(InvalidRange)
  }

  // Get start and end parts
  let mut start_str = ""
  let mut j = 0
  while j < dash_pos {
    start_str = start_str + s[j].unsafe_to_char().to_string()
    j = j + 1
  }
  let mut end_str = ""
  j = dash_pos + 1
  while j < s.length() {
    end_str = end_str + s[j].unsafe_to_char().to_string()
    j = j + 1
  }

  // Trim whitespace
  start_str = rg_trim_string(start_str)
  end_str = rg_trim_string(end_str)
  if start_str.length() == 0 && end_str.length() == 0 {
    return Err(InvalidRange)
  }
  if start_str.length() == 0 {
    // Suffix: -500
    match rg_parse_u64(end_str) {
      Some(length) => Ok(Suffix(length))
      None => Err(InvalidRange)
    }
  } else if end_str.length() == 0 {
    // FromStart: 500-
    match rg_parse_u64(start_str) {
      Some(start) => Ok(FromStart(start))
      None => Err(InvalidRange)
    }
  } else {
    // Range: 0-499
    match (rg_parse_u64(start_str), rg_parse_u64(end_str)) {
      (Some(start), Some(end)) =>
        if start > end {
          Err(InvalidBounds)
        } else {
          Ok(Range(start, end))
        }
      _ => Err(InvalidRange)
    }
  }
}

///|
fn rg_trim_string(s : String) -> String {
  s.trim().to_string()
}

///|
fn rg_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() {
    return 0
  }
  let code = s[idx]
  code.to_int()
}

///|
fn rg_string_slice(s : String, start : Int, end : Int) -> String {
  let mut result = ""
  let mut idx = start
  while idx < end {
    result = result + s[idx].unsafe_to_char().to_string()
    idx = idx + 1
  }
  result
}

///|
fn rg_string_slice_from(s : String, start : Int) -> String {
  let mut result = ""
  let mut idx = start
  let len = s.length()
  while idx < len {
    result = result + s[idx].unsafe_to_char().to_string()
    idx = idx + 1
  }
  result
}

///|
fn rg_find_char(s : String, target : Int) -> Int? {
  let mut idx = 0
  while idx < s.length() {
    if rg_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn rg_split_string(s : String, sep : String) -> Array[String] {
  let result : Array[String] = []
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
      result.push(rg_string_slice(s, start, idx))
      start = idx + sep_len
      idx = start
    } else {
      idx = idx + 1
    }
  }
  result.push(rg_string_slice_from(s, start))
  result
}

///|
fn rg_to_lower_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = rg_char_at(s, idx)
    // Convert A-Z (65-90) to a-z (97-122)
    let new_ch = if ch >= 65 && ch <= 90 { ch + 32 } else { ch }
    result = result + Int::unsafe_to_char(new_ch).to_string()
    idx = idx + 1
  }
  result
}

///|
pub fn rg_parse_u64(s : String) -> UInt64? {
  if s.length() == 0 {
    return None
  }
  let mut result : UInt64 = 0UL
  let mut idx = 0
  let len = s.length()
  while idx < len {
    let ch = rg_char_at(s, idx)
    if ch < 48 || ch > 57 {
      return None
    }

    // Convert digit char to UInt64 by building it up
    let digit = ch - 48 // This gives us Int 0-9
    let digit_u64 = int_digit_to_u64(digit)

    // Check for overflow before multiplying
    // We check if result > (MAX_U64 / 10)
    // MAX_U64 / 10 = 1844674407370955161
    if rg_u64_greater_than(result, 1844674407370955161UL) {
      return None
    }
    result = result * 10UL

    // Check if result > MAX_U64 - digit
    if rg_u64_greater_than(
        result,
        rg_u64_subtract(18446744073709551615UL, digit_u64),
      ) {
      return None
    }
    result = result + digit_u64
    idx = idx + 1
  }
  Some(result)
}

///|
fn int_digit_to_u64(d : Int) -> UInt64 {
  // Convert single digit Int (0-9) to UInt64
  if d == 0 {
    0UL
  } else if d == 1 {
    1UL
  } else if d == 2 {
    2UL
  } else if d == 3 {
    3UL
  } else if d == 4 {
    4UL
  } else if d == 5 {
    5UL
  } else if d == 6 {
    6UL
  } else if d == 7 {
    7UL
  } else if d == 8 {
    8UL
  } else {
    9UL
  }
}

///|
fn rg_u64_greater_than(a : UInt64, b : UInt64) -> Bool {
  a > b
}

///|
fn rg_u64_subtract(a : UInt64, b : UInt64) -> UInt64 {
  // Safe subtraction that returns 0 on underflow
  if b > a {
    0UL
  } else {
    a - b
  }
}

///|
pub fn rg_u64_to_string(n : UInt64) -> String {
  if n == 0UL {
    return "0"
  }
  let chars : Array[String] = []
  let mut num = n
  while num > 0UL {
    let remainder = num % 10UL
    // Convert UInt64 digit (0-9) to Int using subtraction
    let digit_int = u64_digit_to_int(remainder)
    chars.push(Int::unsafe_to_char(digit_int + 48).to_string())
    num = num / 10UL
  }
  let mut result = ""
  let mut idx = chars.length() - 1
  while idx >= 0 {
    result = result + chars[idx]
    if idx == 0 {
      break
    }
    idx = idx - 1
  }
  result
}

///|
fn u64_digit_to_int(d : UInt64) -> Int {
  // Convert a single digit UInt64 (0-9) to Int
  if d == 0UL {
    0
  } else if d == 1UL {
    1
  } else if d == 2UL {
    2
  } else if d == 3UL {
    3
  } else if d == 4UL {
    4
  } else if d == 5UL {
    5
  } else if d == 6UL {
    6
  } else if d == 7UL {
    7
  } else if d == 8UL {
    8
  } else {
    9
  }
}
