///|
/// Cache header parsing errors
pub(all) enum CacheError {
  Empty
  InvalidFormat
  InvalidNumber
  InvalidDate
} derive(Debug, Eq)
