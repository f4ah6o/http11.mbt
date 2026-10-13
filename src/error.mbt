///|
/// HTTP parsing errors
pub(all) enum HttpError {
  InvalidData(String)
  BufferOverflow(Int32, Int32) // size, limit
  TooManyHeaders(Int32, Int32) // count, limit
  HeaderLineTooLong(Int32, Int32) // size, limit
  BodyTooLarge(Int32, Int32) // size, limit
  UnexpectedEof
  InvalidHeaderValue
  InvalidStatusCode
  InvalidChunkSize
} derive(Debug, Eq)
