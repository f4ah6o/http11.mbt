///|
/// HTTP Request representation
pub(all) struct Request {
  http_method : String
  uri : String
  version : String
  headers : Array[(String, String)]
  body : Array[Byte]
} derive(Show, Eq)

///|
pub fn Request::new(http_method : String, uri : String) -> Request {
  { http_method, uri, version: "HTTP/1.1", headers: [], body: [] }
}

///|
pub fn Request::with_version(
  http_method : String,
  uri : String,
  version : String,
) -> Request {
  { http_method, uri, version, headers: [], body: [] }
}

///|
pub fn Request::header(
  self : Request,
  name : String,
  value : String,
) -> Request {
  let new_headers = []
  for h in self.headers {
    new_headers.push(h)
  }
  new_headers.push((name, value))
  { ..self, headers: new_headers }
}

///|
pub fn Request::body(self : Request, body : Array[Byte]) -> Request {
  { ..self, body, }
}

///|
pub fn Request::get_header(self : Request, name : String) -> String? {
  let lower_name = request_string_to_lower(name)
  let mut idx = 0
  while idx < self.headers.length() {
    let (key, value) = self.headers[idx]
    if request_string_to_lower(key) == lower_name {
      return Some(value)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn Request::has_header(self : Request, name : String) -> Bool {
  let lower_name = request_string_to_lower(name)
  let mut idx = 0
  while idx < self.headers.length() {
    let (key, _) = self.headers[idx]
    if request_string_to_lower(key) == lower_name {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
pub fn Request::is_keep_alive(self : Request) -> Bool {
  if self.version == "HTTP/1.1" {
    match self.get_header("connection") {
      Some(v) => request_string_to_lower(v) != "close"
      None => true
    }
  } else if self.version == "HTTP/1.0" {
    match self.get_header("connection") {
      Some(v) => request_string_to_lower(v) == "keep-alive"
      None => false
    }
  } else {
    false
  }
}

///|
pub fn Request::content_length(self : Request) -> Int? {
  match self.get_header("content-length") {
    Some(v) => request_parse_int(v)
    None => None
  }
}

///|
pub fn Request::is_chunked(self : Request) -> Bool {
  match self.get_header("transfer-encoding") {
    Some(v) => request_string_to_lower(v) == "chunked"
    None => false
  }
}

///|
pub fn Request::http_method(self : Request) -> String {
  self.http_method
}

///|
fn request_string_to_lower(s : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < s.length() {
    let c = s[idx]
    let ci = c.to_int()
    let new_c = if ci >= 65 && ci <= 90 {
      Int::unsafe_to_char(ci + 32).to_string()
    } else {
      c.to_string()
    }
    result = result + new_c
    idx = idx + 1
  }
  result
}

///|
fn request_parse_int(s : String) -> Int? {
  let mut result = 0
  let mut idx = 0
  let len = s.length()
  if len == 0 {
    return None
  }
  while idx < len {
    let c = s[idx]
    let ci = c.to_int()
    if ci >= 48 && ci <= 57 {
      result = result * 10 + (ci - 48)
    } else {
      return None
    }
    idx = idx + 1
  }
  Some(result)
}
