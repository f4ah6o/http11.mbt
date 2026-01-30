///|
/// HTTP-date parsing errors
pub(all) enum DateError {
  Empty
  InvalidFormat
  InvalidDayName
  InvalidDay
  InvalidMonth
  InvalidYear
  InvalidHour
  InvalidMinute
  InvalidSecond
  NotGmt
} derive(Show, Eq)

///|
/// Day of week
pub(all) enum DayOfWeek {
  Sunday
  Monday
  Tuesday
  Wednesday
  Thursday
  Friday
  Saturday
} derive(Show, Eq)

///|
/// HTTP-date structure (RFC 9110 Section 5.6.7)
///
/// Supports three formats:
/// - IMF-fixdate: Sun, 06 Nov 1994 08:49:37 GMT (preferred)
/// - RFC 850: Sunday, 06-Nov-94 08:49:37 GMT (obsolete)
/// - ANSI C asctime: Sun Nov  6 08:49:37 1994 (obsolete)
pub(all) struct HttpDate {
  day_of_week : DayOfWeek
  day : Int
  month : Int
  year : Int
  hour : Int
  minute : Int
  second : Int
} derive(Show, Eq)

///|
pub fn HttpDate::new(
  day_of_week : DayOfWeek,
  day : Int,
  month : Int,
  year : Int,
  hour : Int,
  minute : Int,
  second : Int,
) -> Result[HttpDate, DateError] {
  if day < 1 || day > 31 {
    return Err(InvalidDay)
  }
  if month < 1 || month > 12 {
    return Err(InvalidMonth)
  }
  if year < 1 {
    return Err(InvalidYear)
  }
  if hour > 23 {
    return Err(InvalidHour)
  }
  if minute > 59 {
    return Err(InvalidMinute)
  }
  if second > 60 {
    return Err(InvalidSecond)
  }
  Ok({ day_of_week, day, month, year, hour, minute, second })
}

///|
pub fn HttpDate::parse(input : String) -> Result[HttpDate, DateError] {
  let s = trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  // Detect format by comma position
  match date_index_of(s, ",") {
    Some(comma_pos) => {
      let day_name = string_slice(s, 0, comma_pos)
      let rest = trim_string(string_slice_from(s, comma_pos + 1))

      // IMF-fixdate: Sun, 06 Nov 1994 08:49:37 GMT
      // RFC 850: Sunday, 06-Nov-94 08:49:37 GMT
      if date_index_of(rest, "-") != None {
        parse_rfc850(day_name, rest)
      } else {
        parse_imf_fixdate(day_name, rest)
      }
    }
    None =>
      // ANSI C asctime: Sun Nov  6 08:49:37 1994
      parse_asctime(s)
  }
}

///|
pub fn HttpDate::day_of_week(self : HttpDate) -> DayOfWeek {
  self.day_of_week
}

///|
pub fn HttpDate::day(self : HttpDate) -> Int {
  self.day
}

///|
pub fn HttpDate::month(self : HttpDate) -> Int {
  self.month
}

///|
pub fn HttpDate::year(self : HttpDate) -> Int {
  self.year
}

///|
pub fn HttpDate::hour(self : HttpDate) -> Int {
  self.hour
}

///|
pub fn HttpDate::minute(self : HttpDate) -> Int {
  self.minute
}

///|
pub fn HttpDate::second(self : HttpDate) -> Int {
  self.second
}

///|
pub fn HttpDate::to_string(self : HttpDate) -> String {
  let dow = day_of_week_short_name(self.day_of_week)
  let day = if self.day < 10 {
    "0" + self.day.to_string()
  } else {
    self.day.to_string()
  }
  let mon = month_name(self.month)
  let yr = self.year.to_string()
  let hr = if self.hour < 10 {
    "0" + self.hour.to_string()
  } else {
    self.hour.to_string()
  }
  let mn = if self.minute < 10 {
    "0" + self.minute.to_string()
  } else {
    self.minute.to_string()
  }
  let sc = if self.second < 10 {
    "0" + self.second.to_string()
  } else {
    self.second.to_string()
  }
  dow +
  ", " +
  day +
  " " +
  mon +
  " " +
  yr +
  " " +
  hr +
  ":" +
  mn +
  ":" +
  sc +
  " GMT"
}

///|
/// Helper functions

///|
fn day_of_week_short_name(dow : DayOfWeek) -> String {
  match dow {
    Sunday => "Sun"
    Monday => "Mon"
    Tuesday => "Tue"
    Wednesday => "Wed"
    Thursday => "Thu"
    Friday => "Fri"
    Saturday => "Sat"
  }
}

///|
fn day_of_week_from_name(s : String) -> DayOfWeek? {
  match s {
    "Sun" => Some(Sunday)
    "Sunday" => Some(Sunday)
    "Mon" => Some(Monday)
    "Monday" => Some(Monday)
    "Tue" => Some(Tuesday)
    "Tuesday" => Some(Tuesday)
    "Wed" => Some(Wednesday)
    "Wednesday" => Some(Wednesday)
    "Thu" => Some(Thursday)
    "Thursday" => Some(Thursday)
    "Fri" => Some(Friday)
    "Friday" => Some(Friday)
    "Sat" => Some(Saturday)
    "Saturday" => Some(Saturday)
    _ => None
  }
}

///|
fn parse_imf_fixdate(
  day_name : String,
  rest : String,
) -> Result[HttpDate, DateError] {
  match day_of_week_from_name(day_name) {
    None => Err(InvalidDayName)
    Some(dow) => {
      let parts = split_whitespace(rest)
      if parts.length() != 5 {
        return Err(InvalidFormat)
      }
      let day = match date_parse_int(parts[0]) {
        Some(d) => d
        None => return Err(InvalidDay)
      }
      let month = match parse_month(parts[1]) {
        Some(m) => m
        None => return Err(InvalidMonth)
      }
      let year = match date_parse_int(parts[2]) {
        Some(y) => y
        None => return Err(InvalidYear)
      }
      let (hour, minute, second) = match parse_time(parts[3]) {
        Some(t) => t
        None => return Err(InvalidFormat)
      }
      if parts[4] != "GMT" {
        return Err(NotGmt)
      }
      HttpDate::new(dow, day, month, year, hour, minute, second)
    }
  }
}

///|
fn parse_rfc850(
  day_name : String,
  rest : String,
) -> Result[HttpDate, DateError] {
  match day_of_week_from_name(day_name) {
    None => Err(InvalidDayName)
    Some(dow) => {
      let parts = split_whitespace(rest)
      if parts.length() != 3 {
        return Err(InvalidFormat)
      }

      // Parse day-month-year
      let date_parts = split_string(parts[0], "-")
      if date_parts.length() != 3 {
        return Err(InvalidFormat)
      }
      let day = match date_parse_int(date_parts[0]) {
        Some(d) => d
        None => return Err(InvalidDay)
      }
      let month = match parse_month(date_parts[1]) {
        Some(m) => m
        None => return Err(InvalidMonth)
      }
      let mut year = match date_parse_int(date_parts[2]) {
        Some(y) => y
        None => return Err(InvalidYear)
      }

      // RFC 2616 Section 19.3: 2-digit year correction
      // 00-49 -> 2000-2049, 50-99 -> 1950-1999
      if year < 100 {
        year = if year < 50 { 2000 + year } else { 1900 + year }
      }
      let (hour, minute, second) = match parse_time(parts[1]) {
        Some(t) => t
        None => return Err(InvalidFormat)
      }
      if parts[2] != "GMT" {
        return Err(NotGmt)
      }
      HttpDate::new(dow, day, month, year, hour, minute, second)
    }
  }
}

///|
fn parse_asctime(input : String) -> Result[HttpDate, DateError] {
  let parts = split_whitespace(input)
  if parts.length() != 5 {
    return Err(InvalidFormat)
  }
  match day_of_week_from_name(parts[0]) {
    None => Err(InvalidDayName)
    Some(dow) => {
      let month = match parse_month(parts[1]) {
        Some(m) => m
        None => return Err(InvalidMonth)
      }
      let day = match date_parse_int(parts[2]) {
        Some(d) => d
        None => return Err(InvalidDay)
      }
      let (hour, minute, second) = match parse_time(parts[3]) {
        Some(t) => t
        None => return Err(InvalidFormat)
      }
      let year = match date_parse_int(parts[4]) {
        Some(y) => y
        None => return Err(InvalidYear)
      }
      HttpDate::new(dow, day, month, year, hour, minute, second)
    }
  }
}

///|
fn parse_month(s : String) -> Int? {
  match s {
    "Jan" => Some(1)
    "Feb" => Some(2)
    "Mar" => Some(3)
    "Apr" => Some(4)
    "May" => Some(5)
    "Jun" => Some(6)
    "Jul" => Some(7)
    "Aug" => Some(8)
    "Sep" => Some(9)
    "Oct" => Some(10)
    "Nov" => Some(11)
    "Dec" => Some(12)
    _ => None
  }
}

///|
fn month_name(month : Int) -> String {
  match month {
    1 => "Jan"
    2 => "Feb"
    3 => "Mar"
    4 => "Apr"
    5 => "May"
    6 => "Jun"
    7 => "Jul"
    8 => "Aug"
    9 => "Sep"
    10 => "Oct"
    11 => "Nov"
    12 => "Dec"
    _ => "???"
  }
}

///|
fn parse_time(s : String) -> (Int, Int, Int)? {
  let parts = split_string(s, ":")
  if parts.length() != 3 {
    return None
  }
  let hour = match date_parse_int(parts[0]) {
    Some(h) => h
    None => return None
  }
  let minute = match date_parse_int(parts[1]) {
    Some(m) => m
    None => return None
  }
  let second = match date_parse_int(parts[2]) {
    Some(s) => s
    None => return None
  }
  if hour > 23 {
    return None
  }
  if minute > 59 {
    return None
  }
  if second > 60 {
    return None
  }
  Some((hour, minute, second))
}

///|
fn trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = s[start]
    let ci = ch.to_int()
    if ci == 32 || ci == 9 || ci == 10 || ci == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = s[end - 1]
    let ci = ch.to_int()
    if ci == 32 || ci == 9 || ci == 10 || ci == 13 {
      end = end - 1
    } else {
      break
    }
  }
  string_slice(s, start, end)
}

///|
fn date_index_of(s : String, needle : String) -> Int? {
  if needle.length() == 0 {
    return Some(0)
  }
  if needle.length() > s.length() {
    return None
  }
  let mut idx = 0
  while idx <= s.length() - needle.length() {
    let mut is_match = true
    let mut j = 0
    while j < needle.length() {
      if s[idx + j] != needle[j] {
        is_match = false
        break
      }
      j = j + 1
    }
    if is_match {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn split_whitespace(s : String) -> Array[String] {
  let result = []
  let mut current = ""
  let mut in_ws = false
  let mut idx = 0
  let len = s.length()
  while idx < len {
    let ch = s[idx]
    let ci = ch.to_int()
    if ci == 32 || ci == 9 || ci == 10 || ci == 13 {
      if !in_ws && current.length() > 0 {
        result.push(current)
        current = ""
      }
      in_ws = true
    } else {
      let ch_str = Int::unsafe_to_char(ci).to_string()
      current = current + ch_str
      in_ws = false
    }
    idx = idx + 1
  }
  if current.length() > 0 {
    result.push(current)
  }
  result
}

///|
fn split_string(s : String, sep : String) -> Array[String] {
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
      result.push(string_slice(s, start, idx))
      start = idx + sep_len
      idx = start
    } else {
      idx = idx + 1
    }
  }
  result.push(string_slice_from(s, start))
  result
}

///|
fn date_parse_int(s : String) -> Int? {
  let mut result = 0
  let mut idx = 0
  let len = s.length()
  if len == 0 {
    return None
  }
  while idx < len {
    let c = s[idx]
    let ci = c.to_int()
    if ci >= 48 && ci <= 57 {
      result = result * 10 + (ci - 48)
    } else {
      return None
    }
    idx = idx + 1
  }
  Some(result)
}

///|
fn string_slice(s : String, start : Int, end : Int) -> String {
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
fn string_slice_from(s : String, start : Int) -> String {
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
