///|
/// http11.mbt Example Program
/// Demonstrates encoding and decoding of HTTP/1.1 requests and responses

///|

// Helper function to convert bytes to readable string representation
fn bytes_to_string(bytes : Array[Byte]) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < bytes.length() {
    let b = bytes[idx].to_int()
    // Display printable ASCII characters as-is, others as hex
    if b >= 32 && b <= 126 {
      result = result + Int::unsafe_to_char(b).to_string()
    } else if b == 13 {
      result = result + "\\r"
    } else if b == 10 {
      result = result + "\\n\n"
    } else {
      let hex = "0123456789ABCDEF"
      let h1 = hex[(b / 16).min(15)]
      let h2 = hex[(b % 16).min(15)]
      result = result + "\\x" + h1.to_string() + h2.to_string()
    }
    idx = idx + 1
  }
  result
}

///|
fn main {
  println("========================================")
  println("http11.mbt Example Program")
  println("========================================")
  println("")

  // 1. GET Request Example
  println("1. GET Request Example")
  println("---")
  let get_req = @lib.Request::new("GET", "/api/users")
    .header("Host", "example.com")
    .header("Connection", "keep-alive")
    .header("Accept", "application/json")
  let get_encoded = @lib.encode_request(get_req)
  println("Encoded GET request:")
  println(bytes_to_string(get_encoded))
  println("")

  // 2. POST Request with Body Example
  println("2. POST Request with Body Example")
  println("---")
  let post_body = "{\"name\":\"Alice\",\"age\":30}"
  let post_body_bytes : Array[Byte] = []
  let mut i = 0
  while i < post_body.length() {
    post_body_bytes.push(post_body[i].to_byte())
    i = i + 1
  }
  let post_req = @lib.Request::new("POST", "/api/users")
    .header("Host", "example.com")
    .header("Content-Type", "application/json")
    .body(post_body_bytes)
  let post_encoded = @lib.encode_request(post_req)
  println("Encoded POST request:")
  println(bytes_to_string(post_encoded))
  println("")

  // 3. Response Example
  println("3. Response Example")
  println("---")
  let resp_body = "Hello, World!"
  let resp_body_bytes : Array[Byte] = []
  let mut j = 0
  while j < resp_body.length() {
    resp_body_bytes.push(resp_body[j].to_byte())
    j = j + 1
  }
  let resp = @lib.Response::new(200, "OK")
    .header("Content-Type", "text/plain")
    .header("Content-Length", resp_body.length().to_string())
    .body(resp_body_bytes)
  let resp_encoded = @lib.encode_response(resp)
  println("Encoded response:")
  println(bytes_to_string(resp_encoded))
  println("")

  // 4. Chunked Encoding Example
  println("4. Chunked Transfer Encoding Example")
  println("---")
  let chunk1 = "Hello, "
  let chunk2 = "World!"
  let chunk1_bytes : Array[Byte] = []
  let chunk2_bytes : Array[Byte] = []
  let mut k1 = 0
  while k1 < chunk1.length() {
    chunk1_bytes.push(chunk1[k1].to_byte())
    k1 = k1 + 1
  }
  let mut k2 = 0
  while k2 < chunk2.length() {
    chunk2_bytes.push(chunk2[k2].to_byte())
    k2 = k2 + 1
  }
  let chunks = [chunk1_bytes, chunk2_bytes]
  let chunked_encoded = @lib.encode_chunks(chunks)
  println("Encoded chunked data:")
  println(bytes_to_string(chunked_encoded))
  println("")

  // 5. Request Decoder Example
  println("5. Request Decoder Example")
  println("---")
  // Create a raw HTTP request as bytes
  let raw_request = "GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n"
  let raw_bytes : Array[Byte] = []
  for i in 0..<raw_request.length() {
    raw_bytes.push(raw_request[i].to_int().to_byte())
  }
  println("Raw request (\{raw_bytes.length()} bytes):")
  println(bytes_to_string(raw_bytes))
  let decoder = @lib.RequestDecoder::new()
  match decoder.feed(raw_bytes) {
    Ok(_) => println("Feed succeeded")
    Err(e) => println("Feed error: \{e}")
  }
  match decoder.decode() {
    Ok(Some(req)) => {
      println("Decoded request:")
      println("  Method: \{req.http_method}")
      println("  URI: \{req.uri}")
      println("  Version: \{req.version}")
      println("  Headers: \{req.headers.length()}")
    }
    Ok(None) => println("Decode returned None (need more data)")
    Err(e) => println("Decode error: \{e}")
  }
  println("")

  // 6. Response Decoder Example
  println("6. Response Decoder Example")
  println("---")
  println("ResponseDecoder API usage:")
  println("  let decoder = @lib.ResponseDecoder::new()")
  println("  decoder.feed(data)  // Feed raw bytes")
  println("  decoder.decode()    // Try to decode a response")
  println("  Note: Decoder is intended for use with network I/O")
  println("")
  println("========================================")
  println("All examples completed successfully!")
  println("========================================")
}
