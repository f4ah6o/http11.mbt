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
