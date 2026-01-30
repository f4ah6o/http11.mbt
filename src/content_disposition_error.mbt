///|
/// Content-Disposition header parsing errors (RFC 6266)
pub(all) enum ContentDispositionError {
  Empty
  InvalidFormat
  InvalidDispositionType
  InvalidParameter
  InvalidExtValue
} derive(Show, Eq)
