///|
/// Accept header parsing errors (RFC 9110 Section 12.5)
pub(all) enum AcceptError {
  Empty
  InvalidFormat
  InvalidMediaRange
  InvalidToken
  InvalidParameter
  InvalidQValue
  InvalidLanguageTag
} derive(Show, Eq)
