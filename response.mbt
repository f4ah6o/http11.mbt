///|
/// HTTP Response representation
pub(all) struct Response {
  version : String
  status_code : Int
  reason_phrase : String
  headers : Array[(String, String)]
  body : Array[Byte]
} derive(Show, Eq)

///|
pub fn Response::new(status_code : Int, reason_phrase : String) -> Response {
  { version: "HTTP/1.1", status_code, reason_phrase, headers: [], body: [] }
}

///|
pub fn Response::with_version(
  version : String,
  status_code : Int,
  reason_phrase : String,
) -> Response {
  { version, status_code, reason_phrase, headers: [], body: [] }
}

///|
pub fn Response::is_success(self : Response) -> Bool {
  self.status_code >= 200 && self.status_code < 300
}

///|
pub fn Response::is_redirect(self : Response) -> Bool {
  self.status_code >= 300 && self.status_code < 400
}

///|
pub fn Response::is_client_error(self : Response) -> Bool {
  self.status_code >= 400 && self.status_code < 500
}

///|
pub fn Response::is_server_error(self : Response) -> Bool {
  self.status_code >= 500 && self.status_code < 600
}

///|
pub fn Response::header(
  self : Response,
  name : String,
  value : String,
) -> Response {
  let new_headers = []
  for h in self.headers {
    new_headers.push(h)
  }
  new_headers.push((name, value))
  { ..self, headers: new_headers }
}

///|
pub fn Response::body(self : Response, body : Array[Byte]) -> Response {
  { ..self, body, }
}

///|
pub fn Response::get_header(self : Response, name : String) -> String? {
  let lower_name = response_string_to_lower(name)
  let mut idx = 0
  while idx < self.headers.length() {
    let (key, value) = self.headers[idx]
    if response_string_to_lower(key) == lower_name {
      return Some(value)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn Response::has_header(self : Response, name : String) -> Bool {
  let lower_name = response_string_to_lower(name)
  let mut idx = 0
  while idx < self.headers.length() {
    let (key, _) = self.headers[idx]
    if response_string_to_lower(key) == lower_name {
      return true
    }
    idx = idx + 1
  }
  false
}

///|
pub fn Response::is_keep_alive(self : Response) -> Bool {
  if self.version == "HTTP/1.1" {
    match self.get_header("connection") {
      Some(v) => response_string_to_lower(v) != "close"
      None => true
    }
  } else if self.version == "HTTP/1.0" {
    match self.get_header("connection") {
      Some(v) => response_string_to_lower(v) == "keep-alive"
      None => false
    }
  } else {
    false
  }
}

///|
pub fn Response::content_length(self : Response) -> Int? {
  match self.get_header("content-length") {
    Some(v) => response_parse_int(v)
    None => None
  }
}

///|
pub fn Response::is_chunked(self : Response) -> Bool {
  match self.get_header("transfer-encoding") {
    Some(v) => response_string_to_lower(v) == "chunked"
    None => false
  }
}

///|
fn response_string_to_lower(s : String) -> String {
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
fn response_parse_int(s : String) -> Int? {
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
