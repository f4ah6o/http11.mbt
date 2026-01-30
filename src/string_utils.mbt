///|
fn str_char_at(s : String, idx : Int) -> Int {
  if idx >= s.length() {
    return 0
  }
  let ch = s[idx]
  ch.to_int()
}

///|
fn str_string_slice(s : String, start : Int, end : Int) -> String {
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
fn str_string_slice_from(s : String, start : Int) -> String {
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
fn str_trim_string(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = str_char_at(s, start)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = str_char_at(s, end - 1)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      end = end - 1
    } else {
      break
    }
  }
  str_string_slice(s, start, end)
}

///|
fn str_to_lower_case(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let ch = str_char_at(s, idx)
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
fn str_split_string(s : String, sep : String) -> Array[String] {
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
      result.push(str_string_slice(s, start, idx))
      start = idx + sep_len
      idx = start
    } else {
      idx = idx + 1
    }
  }
  result.push(str_string_slice_from(s, start))
  result
}

///|
fn str_split_char(s : String, sep : Int) -> Array[String] {
  let mut result = []
  let mut start = 0
  let mut idx = 0
  while idx < s.length() {
    let ch = str_char_at(s, idx)
    if ch == sep {
      let new_result = []
      let mut j = 0
      while j < result.length() {
        new_result.push(result[j])
        j = j + 1
      }
      new_result.push(str_string_slice(s, start, idx))
      result = new_result
      start = idx + 1
    }
    idx = idx + 1
  }
  let new_result = []
  let mut j = 0
  while j < result.length() {
    new_result.push(result[j])
    j = j + 1
  }
  new_result.push(str_string_slice_from(s, start))
  result = new_result
  result
}
