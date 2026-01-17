///|
/// Encode an HTTP request to bytes
pub fn encode_request(request : Request) -> Array[Byte] {
  let headers_part = encode_request_headers(request)
  let body_part = request.body
  array_append(headers_part, body_part)
}

///|
/// Encode an HTTP response to bytes
pub fn encode_response(response : Response) -> Array[Byte] {
  let headers_part = encode_response_headers(response)
  let body_part = response.body
  array_append(headers_part, body_part)
}

///|
/// Encode only the headers part of an HTTP request
pub fn encode_request_headers(request : Request) -> Array[Byte] {
  let line = request.http_method + " " + request.uri + " " + request.version + "\r\n"
  let mut result = string_to_bytes(line)
  for item in request.headers {
    let (name, value) = item
    let h = name + ": " + value + "\r\n"
    result = array_append(result, string_to_bytes(h))
  }
  result = array_append(result, string_to_bytes("\r\n"))
  result
}

///|
/// Encode only the headers part of an HTTP response
pub fn encode_response_headers(response : Response) -> Array[Byte] {
  let line = response.version + " " + response.status_code.to_string() + " " + response.reason_phrase + "\r\n"
  let mut result = string_to_bytes(line)
  for item in response.headers {
    let (name, value) = item
    let h = name + ": " + value + "\r\n"
    result = array_append(result, string_to_bytes(h))
  }
  result = array_append(result, string_to_bytes("\r\n"))
  result
}

///|
/// Encode a single chunk of chunked transfer encoding
pub fn encode_chunk(data : Array[Byte]) -> Array[Byte] {
  let size = data.length()
  let size_str = int_to_hex(size) + "\r\n"
  let mut result = string_to_bytes(size_str)
  result = array_append(result, data)
  result = array_append(result, string_to_bytes("\r\n"))
  result
}

///|
/// Encode multiple chunks of chunked transfer encoding
pub fn encode_chunks(chunks : Array[Array[Byte]]) -> Array[Byte] {
  let mut result = []
  for chunk in chunks {
    result = array_append(result, encode_chunk(chunk))
  }
  result = array_append(result, string_to_bytes("0\r\n\r\n"))
  result
}

///|
fn array_append(a : Array[Byte], b : Array[Byte]) -> Array[Byte] {
  let result = a
  for byte in b {
    result.push(byte)
  }
  result
}

///|
fn string_to_bytes(s : String) -> Array[Byte] {
  let result = []
  let mut idx = 0
  while idx < s.length() {
    result.push(s[idx].to_int().to_byte())
    idx = idx + 1
  }
  result
}

///|
fn int_to_hex(n : Int) -> String {
  let hex = "0123456789abcdef"
  if n == 0 {
    return "0"
  }
  let mut result = ""
  let mut num = n
  while num > 0 {
    let digit = num % 16
    result = hex[digit].to_string() + result
    num = num / 16
  }
  result
}
