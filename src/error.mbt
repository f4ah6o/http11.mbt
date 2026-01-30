///|
/// HTTP parsing errors
pub(all) enum HttpError {
  InvalidData(String)
  BufferOverflow(Int, Int) // size, limit
  TooManyHeaders(Int, Int) // count, limit
  HeaderLineTooLong(Int, Int) // size, limit
  BodyTooLarge(Int, Int) // size, limit
  UnexpectedEof
  InvalidHeaderValue
  InvalidStatusCode
  InvalidChunkSize
} derive(Show, Eq)
