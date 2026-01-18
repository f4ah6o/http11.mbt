///|
/// http11.mbt HTTP Server Example
/// Similar to http11-rs http11_server example

///|
fn bytes_to_array(b : Bytes) -> Array[Byte] {
  let arr : Array[Byte] = []
  for i in 0..<b.length() {
    arr.push(b[i])
  }
  arr
}

///|
fn string_to_bytes(s : String) -> Array[Byte] {
  let result : Array[Byte] = []
  for i in 0..<s.length() {
    result.push(s[i].to_int().to_byte())
  }
  result
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
fn build_html_response() -> @lib.Response {
  let body = "<!DOCTYPE html>\n<html>\n<head><title>http11.mbt Server</title></head>\n<body>\n<h1>Welcome to http11.mbt!</h1>\n<p>A pure MoonBit HTTP/1.1 implementation.</p>\n<ul>\n<li><a href=\"/\">Home</a></li>\n<li><a href=\"/info\">Server Info (JSON)</a></li>\n<li><a href=\"/echo\">Echo Request</a></li>\n</ul>\n</body>\n</html>"
  let body_bytes = string_to_bytes(body)
  @lib.Response::new(200, "OK")
    .header("Content-Type", "text/html; charset=utf-8")
    .header("Content-Length", body_bytes.length().to_string())
    .header("Connection", "close")
    .body(body_bytes)
}

///|
fn build_json_response() -> @lib.Response {
  let body = "{\"server\":\"http11.mbt\",\"version\":\"0.1.0\",\"language\":\"MoonBit\"}"
  let body_bytes = string_to_bytes(body)
  @lib.Response::new(200, "OK")
    .header("Content-Type", "application/json")
    .header("Content-Length", body_bytes.length().to_string())
    .header("Connection", "close")
    .body(body_bytes)
}

///|
fn build_echo_response(request : @lib.Request) -> @lib.Response {
  let mut body = "Method: " + request.http_method + "\n"
  body = body + "URI: " + request.uri + "\n"
  body = body + "Version: " + request.version + "\n"
  body = body + "Headers:\n"
  for h in request.headers {
    let (name, value) = h
    body = body + "  " + name + ": " + value + "\n"
  }
  if request.body.length() > 0 {
    body = body + "Body:\n" + body_to_string(request.body) + "\n"
  }
  let body_bytes = string_to_bytes(body)
  @lib.Response::new(200, "OK")
    .header("Content-Type", "text/plain; charset=utf-8")
    .header("Content-Length", body_bytes.length().to_string())
    .header("Connection", "close")
    .body(body_bytes)
}

///|
fn build_not_found_response() -> @lib.Response {
  let body = "404 Not Found"
  let body_bytes = string_to_bytes(body)
  @lib.Response::new(404, "Not Found")
    .header("Content-Type", "text/plain")
    .header("Content-Length", body_bytes.length().to_string())
    .header("Connection", "close")
    .body(body_bytes)
}

///|
fn build_response(request : @lib.Request) -> @lib.Response {
  match request.uri {
    "/" => build_html_response()
    "/info" => build_json_response()
    "/echo" => build_echo_response(request)
    _ => build_not_found_response()
  }
}

///|
async fn main {
  println("HTTP server listening on http://0.0.0.0:8080")
  println("Try:")
  println("  curl http://localhost:8080/")
  println("  curl http://localhost:8080/info")
  println("  curl http://localhost:8080/echo")
  @socket.TcpServer::new(
    @socket.Addr::parse("0.0.0.0:8080"),
    reuse_addr=true,
  ).run_forever(fn(conn, _peer_addr) {
    let decoder = @lib.RequestDecoder::new()
    while conn.read_some() is Some(data) {
      match decoder.feed(bytes_to_array(data)) {
        Err(_) => {
          let response_str = "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\nConnection: close\r\n\r\nBad Request"
          conn.write(array_to_bytes(string_to_bytes(response_str)))
          return
        }
        Ok(_) => ()
      }
      match decoder.decode() {
        Ok(Some(request)) => {
          let response = build_response(request)
          let response_bytes = @lib.encode_response(response)
          conn.write(array_to_bytes(response_bytes))
          return
        }
        Ok(None) | Err(@lib.HttpError::UnexpectedEof) => ()
        Err(_) => {
          let response_str = "HTTP/1.1 400 Bad Request\r\nContent-Length: 11\r\nConnection: close\r\n\r\nBad Request"
          conn.write(array_to_bytes(string_to_bytes(response_str)))
          return
        }
      }
    }
  })
}
