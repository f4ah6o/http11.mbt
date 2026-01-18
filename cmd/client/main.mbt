///|
/// http11.mbt HTTP Client Example
/// Similar to http11-rs http11_client example

///|
fn bytes_to_array(b : Bytes) -> Array[Byte] {
  let arr : Array[Byte] = []
  for i in 0..<b.length() {
    arr.push(b[i])
  }
  arr
}

///|
fn array_to_bytes(arr : Array[Byte]) -> Bytes {
  Bytes::from_array(arr)
}

///|
fn body_to_string(body : Array[Byte]) -> String {
  let mut result = ""
  for b in body {
    result = result + Int::unsafe_to_char(b.to_int()).to_string()
  }
  result
}

///|
fn string_slice(s : String, start : Int, end : Int) -> String {
  let mut result = ""
  for i in start..<end {
    if i < s.length() {
      result = result + Int::unsafe_to_char(s[i].to_int()).to_string()
    }
  }
  result
}

///|
fn string_slice_from(s : String, start : Int) -> String {
  string_slice(s, start, s.length())
}

///|
/// Parse a simple URL like http://host:port/path
/// Returns (host, port, path)
fn parse_url(url : String) -> (String, Int, String) {
  // Remove http:// prefix if present
  let mut rest = url
  if url.has_prefix("http://") {
    rest = string_slice_from(url, 7)
  }

  // Find path separator
  let mut host_port = rest
  let mut path = "/"
  for i in 0..<rest.length() {
    if rest[i] == '/' {
      host_port = string_slice(rest, 0, i)
      path = string_slice_from(rest, i)
      break
    }
  }

  // Find port separator
  let mut host = host_port
  let mut port = 80
  for i in 0..<host_port.length() {
    if host_port[i] == ':' {
      host = string_slice(host_port, 0, i)
      let port_str = string_slice_from(host_port, i + 1)
      port = parse_port(port_str)
      break
    }
  }

  (host, port, path)
}

///|
fn parse_port(s : String) -> Int {
  let mut result = 0
  for i in 0..<s.length() {
    let c = s[i]
    let ci = c.to_int()
    if ci >= 48 && ci <= 57 {
      result = result * 10 + (ci - 48)
    } else {
      break
    }
  }
  if result == 0 { 80 } else { result }
}

///|
fn print_response(response : @lib.Response) -> Unit {
  println("\{response.version} \{response.status_code} \{response.reason_phrase}")
  for h in response.headers {
    let (name, value) = h
    println("\{name}: \{value}")
  }
  println("")
  println("Body length: \{response.body.length()}")
  if response.body.length() > 0 {
    println(body_to_string(response.body))
  }
}

///|
async fn main {
  // Default URL - in a real CLI app, this would come from command line args
  let url = "http://127.0.0.1:8080/"
  println("Fetching \{url}...")
  println("")

  let (host, port, path) = parse_url(url)

  // Build request
  let request = @lib.Request::new("GET", path)
    .header("Host", host)
    .header("User-Agent", "http11.mbt/0.1.0")
    .header("Accept", "*/*")
    .header("Connection", "close")
  let request_bytes = @lib.encode_request(request)

  // Connect to server
  let addr = @socket.Addr::parse("\{host}:\{port}")
  let conn = @socket.Tcp::connect(addr)

  // Send request
  conn.write(array_to_bytes(request_bytes))

  // Receive response
  let decoder = @lib.ResponseDecoder::new()
  while conn.read_some() is Some(data) {
    match decoder.feed(bytes_to_array(data)) {
      Err(e) => {
        println("Error feeding data: \{e}")
        break
      }
      Ok(_) => ()
    }
    match decoder.decode() {
      Ok(Some(response)) => {
        print_response(response)
        break
      }
      Ok(None) | Err(@lib.HttpError::UnexpectedEof) => ()
      Err(e) => {
        println("Error decoding response: \{e}")
        break
      }
    }
  }

  conn.close()
}
