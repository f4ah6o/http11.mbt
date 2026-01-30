///|
/// Age header (RFC 9111 Section 5.1)
pub(all) struct Age {
  seconds : Int
} derive(Eq)

///|
pub fn Age::new(seconds : Int) -> Age {
  { seconds, }
}

///|
pub fn Age::parse(input : String) -> Result[Age, CacheError] {
  let s = cc_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  match cc_parse_u64(s) {
    Some(secs) => Ok({ seconds: secs })
    None => Err(InvalidNumber)
  }
}

///|
pub fn Age::seconds(self : Age) -> Int {
  self.seconds
}

///|
pub fn Age::to_string(self : Age) -> String {
  self.seconds.to_string()
}
