///|
/// Cookie parsing errors (RFC 6265)
pub(all) enum CookieError {
  Empty
  InvalidFormat
  InvalidName
  InvalidValue
  InvalidAttribute
  InvalidExpires
  InvalidMaxAge
  InvalidSameSite
} derive(Show, Eq)
