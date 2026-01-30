///|
/// Digest value (RFC 9530 section 4)
/// Format: :base64:
pub(all) struct DigestValue {
  bytes : Array[Byte]
} derive(Eq)

///|
pub fn DigestValue::new(bytes : Array[Byte]) -> DigestValue {
  { bytes, }
}

///|
pub fn DigestValue::bytes(self : DigestValue) -> Array[Byte] {
  self.bytes
}

///|
pub fn DigestValue::to_string(self : DigestValue) -> String {
  ":" + df_base64_encode(self.bytes) + ":"
}

///|
/// Digest entry (algorithm + digest value)
pub(all) struct DigestEntry {
  algorithm : String
  value : DigestValue
} derive(Eq)

///|
pub fn DigestEntry::new(algorithm : String, value : DigestValue) -> DigestEntry {
  { algorithm, value }
}

///|
pub fn DigestEntry::algorithm(self : DigestEntry) -> String {
  self.algorithm
}

///|
pub fn DigestEntry::value(self : DigestEntry) -> DigestValue {
  self.value
}

///|
pub fn DigestEntry::to_string(self : DigestEntry) -> String {
  self.algorithm + "=" + self.value.to_string()
}
