///|
/// Digest Fields (RFC 9530)
/// Content-Digest, Repr-Digest, Want-Content-Digest, Want-Repr-Digest
///

///|
/// Digest fields error types
pub(all) enum DigestFieldsError {
  Empty
  InvalidFormat
  InvalidAlgorithm
  InvalidByteSequence
  InvalidBase64
  InvalidPreference
} derive(Show, Eq)
