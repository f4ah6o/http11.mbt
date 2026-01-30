///|
/// HTTP Authentication (Basic / Digest / Bearer)
/// RFC 7617 (Basic), RFC 7616 (Digest), RFC 6750 (Bearer)

///|

///|
/// Authentication error types
pub(all) enum AuthError {
  Empty
  InvalidFormat
  NotBasicScheme
  NotDigestScheme
  NotBearerScheme
  Base64DecodeError
  Utf8Error
  MissingColon
  InvalidParameter
  MissingParameter
  InvalidToken
} derive(Show, Eq)
