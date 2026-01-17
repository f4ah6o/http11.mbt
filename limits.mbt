///|
/// Decoder limits to prevent resource exhaustion
pub(all) struct DecoderLimits {
  max_buffer_size : Int
  max_headers_count : Int
  max_header_line_size : Int
  max_body_size : Int
} derive(Show, Eq)

///|
pub fn DecoderLimits::default() -> DecoderLimits {
  { max_buffer_size: 65536, max_headers_count: 100, max_header_line_size: 8192, max_body_size: 10485760 }
}

///|
pub fn DecoderLimits::unlimited() -> DecoderLimits {
  { max_buffer_size: 2147483647, max_headers_count: 2147483647, max_header_line_size: 2147483647, max_body_size: 2147483647 }
}
