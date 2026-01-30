///|
/// Expires header (RFC 9111 Section 5.3)
pub(all) struct Expires {
  date : HttpDate
} derive(Eq)

///|
pub fn Expires::new(date : HttpDate) -> Expires {
  { date, }
}

///|
pub fn Expires::parse(input : String) -> Result[Expires, CacheError] {
  match HttpDate::parse(input) {
    Ok(date) => Ok({ date, })
    Err(_) => Err(InvalidDate)
  }
}

///|
pub fn Expires::date(self : Expires) -> HttpDate {
  self.date
}

///|
pub fn Expires::to_string(self : Expires) -> String {
  self.date.to_string()
}
