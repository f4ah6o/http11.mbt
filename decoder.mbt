///|
/// Body parsing modes
priv enum BodyMode {
  None
  ContentLength(Int)
  Chunked
}

///|
/// Decoder state machine
pub(all) enum DecodeState {
  Start
  StartLine
  Headers
  Body(Int)
  Complete
} derive(Show, Eq)

///|
/// Sans I/O HTTP request decoder
pub(all) struct RequestDecoder {
  mut buf : Array[Byte]
  mut state : DecodeState
  mut parsed_method : String?
  mut parsed_uri : String?
  mut parsed_version : String?
  mut headers : Array[(String, String)]
  mut body_buf : Array[Byte]
  mut content_length : Int?
  limits : DecoderLimits
} derive(Show)

///|
pub fn RequestDecoder::new() -> RequestDecoder {
  {
    buf: [],
    state: Start,
    parsed_method: None,
    parsed_uri: None,
    parsed_version: None,
    headers: [],
    body_buf: [],
    content_length: None,
    limits: DecoderLimits::default()
  }
}

///|
pub fn RequestDecoder::with_limits(limits : DecoderLimits) -> RequestDecoder {
  {
    buf: [],
    state: Start,
    parsed_method: None,
    parsed_uri: None,
    parsed_version: None,
    headers: [],
    body_buf: [],
    content_length: None,
    limits
  }
}

///|
pub fn RequestDecoder::feed(self : RequestDecoder, data : Array[Byte]) -> Result[Unit, HttpError] {
  let new_len = self.buf.length() + data.length()
  if new_len > self.limits.max_buffer_size {
    return Err(BufferOverflow(new_len, self.limits.max_buffer_size))
  }
  self.buf = decoder_array_append(self.buf, data)
  Ok(())
}

///|
pub fn RequestDecoder::decode(self : RequestDecoder) -> Result[Request?, HttpError] {
  match self.state {
    Complete => {
      if self.buf.length() > 0 {
        self.reset()
        self.decode()
      } else {
        Ok(None)
      }
    }
    Start => {
      self.state = StartLine
      self.decode()
    }
    StartLine => {
      match read_crlf_line(self.buf, self.limits.max_header_line_size) {
        Err(e) => Err(e)
        Ok(line_and_rest) => {
          let (line, remaining) = line_and_rest
          self.buf = remaining
          if line.length() == 0 {
            Ok(None)
          } else {
            match parse_request_line(line) {
              Ok(parts) => {
                let (http_method, uri, version) = parts
                self.parsed_method = Some(http_method)
                self.parsed_uri = Some(uri)
                self.parsed_version = Some(version)
                self.state = Headers
                self.decode()
              }
              Err(e) => Err(e)
            }
          }
        }
      }
    }
    Headers => {
      match read_crlf_line(self.buf, self.limits.max_header_line_size) {
        Err(e) => Err(e)
        Ok(line_and_rest) => {
          let (line, remaining) = line_and_rest
          self.buf = remaining
          if line.length() == 0 {
            match determine_body_mode(self.headers) {
              Err(e) => Err(e)
              Ok(mode) => {
                match mode {
                  None => {
                    self.state = Complete
                    self.build_request()
                  }
                  ContentLength(len) => {
                    self.content_length = Some(len)
                    self.state = Body(len)
                    self.decode()
                  }
                  Chunked => {
                    self.state = Complete
                    self.build_request()
                  }
                }
              }
            }
          } else {
            match parse_header_line(line) {
              Err(e) => Err(e)
              Ok(header) => {
                let (name, value) = header
                self.headers.push((name, value))
                if self.headers.length() > self.limits.max_headers_count {
                  Err(TooManyHeaders(self.headers.length(), self.limits.max_headers_count))
                } else {
                  self.decode()
                }
              }
            }
          }
        }
      }
    }
    Body(content_length) => {
      let have = self.body_buf.length()
      let needed = content_length - have
      let available = self.buf.length()
      let take = if needed < available { needed } else { available }

      let split_result = split_at(self.buf, take)
      let (to_take, rest) = split_result
      self.body_buf = decoder_array_append(self.body_buf, to_take)
      self.buf = rest

      if self.body_buf.length() >= content_length {
        self.state = Complete
        self.build_request()
      } else {
        Ok(None)
      }
    }
  }
}

///|
pub fn RequestDecoder::reset(self : RequestDecoder) -> Unit {
  self.buf = []
  self.state = Start
  self.parsed_method = None
  self.parsed_uri = None
  self.parsed_version = None
  self.headers = []
  self.body_buf = []
  self.content_length = None
}

///|
pub fn RequestDecoder::remaining(self : RequestDecoder) -> Array[Byte] {
  self.buf
}

///|
fn RequestDecoder::build_request(self : RequestDecoder) -> Result[Request?, HttpError] {
  match (self.parsed_method, self.parsed_uri) {
    (Some(http_method), Some(uri)) => {
      let version = match self.parsed_version {
        Some(v) => v
        None => "HTTP/1.1"
      }
      let mut req = Request::with_version(http_method, uri, version)
      for item in self.headers {
        let (name, value) = item
        req = req.header(name, value)
      }
      req = req.body(self.body_buf)
      Ok(Some(req))
    }
    _ => Ok(None)
  }
}

///|
/// Sans I/O HTTP response decoder
pub(all) struct ResponseDecoder {
  mut buf : Array[Byte]
  mut state : DecodeState
  mut parsed_version : String?
  mut parsed_status_code : Int?
  mut parsed_reason : String?
  mut headers : Array[(String, String)]
  mut body_buf : Array[Byte]
  mut content_length : Int?
  limits : DecoderLimits
} derive(Show)

///|
pub fn ResponseDecoder::new() -> ResponseDecoder {
  {
    buf: [],
    state: Start,
    parsed_version: None,
    parsed_status_code: None,
    parsed_reason: None,
    headers: [],
    body_buf: [],
    content_length: None,
    limits: DecoderLimits::default()
  }
}

///|
pub fn ResponseDecoder::with_limits(limits : DecoderLimits) -> ResponseDecoder {
  {
    buf: [],
    state: Start,
    parsed_version: None,
    parsed_status_code: None,
    parsed_reason: None,
    headers: [],
    body_buf: [],
    content_length: None,
    limits
  }
}

///|
pub fn ResponseDecoder::feed(self : ResponseDecoder, data : Array[Byte]) -> Result[Unit, HttpError] {
  let new_len = self.buf.length() + data.length()
  if new_len > self.limits.max_buffer_size {
    return Err(BufferOverflow(new_len, self.limits.max_buffer_size))
  }
  self.buf = decoder_array_append(self.buf, data)
  Ok(())
}

///|
pub fn ResponseDecoder::decode(self : ResponseDecoder) -> Result[Response?, HttpError] {
  match self.state {
    Complete => {
      if self.buf.length() > 0 {
        self.reset()
        self.decode()
      } else {
        Ok(None)
      }
    }
    Start => {
      self.state = StartLine
      self.decode()
    }
    StartLine => {
      match read_crlf_line(self.buf, self.limits.max_header_line_size) {
        Err(e) => Err(e)
        Ok(line_and_rest) => {
          let (line, remaining) = line_and_rest
          self.buf = remaining
          if line.length() == 0 {
            Ok(None)
          } else {
            match parse_status_line(line) {
              Err(e) => Err(e)
              Ok(parts) => {
                let (version, status_code, reason) = parts
                self.parsed_version = Some(version)
                self.parsed_status_code = Some(status_code)
                self.parsed_reason = Some(reason)
                self.state = Headers
                self.decode()
              }
            }
          }
        }
      }
    }
    Headers => {
      match read_crlf_line(self.buf, self.limits.max_header_line_size) {
        Err(e) => Err(e)
        Ok(line_and_rest) => {
          let (line, remaining) = line_and_rest
          self.buf = remaining
          if line.length() == 0 {
            match determine_body_mode(self.headers) {
              Err(e) => Err(e)
              Ok(mode) => {
                match mode {
                  None => {
                    self.state = Complete
                    self.build_response()
                  }
                  ContentLength(len) => {
                    self.content_length = Some(len)
                    self.state = Body(len)
                    self.decode()
                  }
                  Chunked => {
                    self.state = Complete
                    self.build_response()
                  }
                }
              }
            }
          } else {
            match parse_header_line(line) {
              Err(e) => Err(e)
              Ok(header) => {
                let (name, value) = header
                self.headers.push((name, value))
                if self.headers.length() > self.limits.max_headers_count {
                  Err(TooManyHeaders(self.headers.length(), self.limits.max_headers_count))
                } else {
                  self.decode()
                }
              }
            }
          }
        }
      }
    }
    Body(content_length) => {
      let have = self.body_buf.length()
      let needed = content_length - have
      let available = self.buf.length()
      let take = if needed < available { needed } else { available }

      let split_result = split_at(self.buf, take)
      let (to_take, rest) = split_result
      self.body_buf = decoder_array_append(self.body_buf, to_take)
      self.buf = rest

      if self.body_buf.length() >= content_length {
        self.state = Complete
        self.build_response()
      } else {
        Ok(None)
      }
    }
  }
}

///|
pub fn ResponseDecoder::reset(self : ResponseDecoder) -> Unit {
  self.buf = []
  self.state = Start
  self.parsed_version = None
  self.parsed_status_code = None
  self.parsed_reason = None
  self.headers = []
  self.body_buf = []
  self.content_length = None
}

///|
pub fn ResponseDecoder::remaining(self : ResponseDecoder) -> Array[Byte] {
  self.buf
}

///|
fn ResponseDecoder::build_response(self : ResponseDecoder) -> Result[Response?, HttpError] {
  match (self.parsed_version, self.parsed_status_code) {
    (Some(version), Some(status_code)) => {
      let reason = match self.parsed_reason {
        Some(r) => r
        None => ""
      }
      let mut resp = Response::with_version(version, status_code, reason)
      for item in self.headers {
        let (name, value) = item
        resp = resp.header(name, value)
      }
      resp = resp.body(self.body_buf)
      Ok(Some(resp))
    }
    _ => Ok(None)
  }
}

///|
/// Helper functions
///|
fn decoder_array_append(a : Array[Byte], b : Array[Byte]) -> Array[Byte] {
  let result = a
  for byte in b {
    result.push(byte)
  }
  result
}

///|
fn split_at(arr : Array[Byte], n : Int) -> (Array[Byte], Array[Byte]) {
  let first = []
  let mut idx = 0
  while idx < n && idx < arr.length() {
    first.push(arr[idx])
    idx = idx + 1
  }
  let second = []
  while idx < arr.length() {
    second.push(arr[idx])
    idx = idx + 1
  }
  (first, second)
}

///|
fn read_crlf_line(buf : Array[Byte], max_size : Int) -> Result[(String, Array[Byte]), HttpError] {
  let mut i = 0
  let len = buf.length()
  while i < len - 1 {
    if buf[i] == 13 && buf[i + 1] == 10 {
      if i > max_size {
        return Err(HeaderLineTooLong(i, max_size))
      }
      let line = decoder_bytes_to_string_slice(buf, 0, i)
      let remaining = decoder_bytes_slice(buf, i + 2, len)
      return Ok((line, remaining))
    }
    i = i + 1
  }
  Err(UnexpectedEof)
}

///|
fn decoder_bytes_to_string_slice(arr : Array[Byte], start : Int, end : Int) -> String {
  let mut result = ""
  let mut i = start
  while i < end {
    result = result + arr[i].to_string()
    i = i + 1
  }
  result
}

///|
fn decoder_bytes_slice(arr : Array[Byte], start : Int, end : Int) -> Array[Byte] {
  let result = []
  let mut i = start
  while i < end {
    result.push(arr[i])
    i = i + 1
  }
  result
}

///|
fn parse_request_line(line : String) -> Result[(String, String, String), HttpError] {
  let parts = split_to_array(line, " ")
  if parts.length() < 2 {
    return Err(InvalidData("Invalid request line"))
  }
  let http_method = parts[0]
  let uri = parts[1]
  let version = if parts.length() >= 3 { parts[2] } else { "HTTP/1.1" }
  Ok((http_method, uri, version))
}

///|
fn parse_status_line(line : String) -> Result[(String, Int, String), HttpError] {
  let parts = split_to_array(line, " ")
  if parts.length() < 2 {
    return Err(InvalidData("Invalid status line"))
  }
  let version = parts[0]
  let status_code = match decoder_parse_int(parts[1]) {
    Some(n) => n
    None => return Err(InvalidStatusCode)
  }
  let reason = if parts.length() >= 3 {
    let mut r = ""
    let mut i = 2
    while i < parts.length() {
      if i > 2 { r = r + " " }
      r = r + parts[i]
      i = i + 1
    }
    r
  } else {
    ""
  }
  Ok((version, status_code, reason))
}

///|
fn parse_header_line(line : String) -> Result[(String, String), HttpError] {
  let colon_idx = decoder_string_index_of(line, ":")
  match colon_idx {
    Some(idx) => {
      let name = line.substring(start=0, end=idx)
      let value = line.substring(start=idx + 1, end=line.length())
      let trimmed = trim_whitespace(value)
      if name.length() == 0 {
        Err(InvalidHeaderValue)
      } else {
        Ok((name, trimmed))
      }
    }
    None => Err(InvalidHeaderValue)
  }
}

///|
fn trim_whitespace(s : String) -> String {
  let mut start = 0
  let len = s.length()
  while start < len {
    let ch = s[start]
    if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' {
      start = start + 1
    } else {
      break
    }
  }
  let mut end = len
  while end > start {
    let ch = s[end - 1]
    if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' {
      end = end - 1
    } else {
      break
    }
  }
  s.substring(start=start, end=end)
}

///|
fn determine_body_mode(headers : Array[(String, String)]) -> Result[BodyMode, HttpError] {
  let mut idx = 0
  while idx < headers.length() {
    let (name, value) = headers[idx]
    if decoder_string_to_lower(name) == "transfer-encoding" && decoder_string_to_lower(value) == "chunked" {
      return Ok(Chunked)
    }
    idx = idx + 1
  }

  idx = 0
  while idx < headers.length() {
    let (name, value) = headers[idx]
    if decoder_string_to_lower(name) == "content-length" {
      match decoder_parse_int(value) {
        Some(len) => {
          if len < 0 {
            return Err(InvalidData("Negative content-length"))
          }
          return Ok(ContentLength(len))
        }
        None => return Err(InvalidData("Invalid content-length"))
      }
    }
    idx = idx + 1
  }

  Ok(None)
}

///|
fn decoder_string_to_lower(s : String) -> String {
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
fn decoder_string_index_of(s : String, needle : String) -> Int? {
  if needle.length() == 0 {
    return Some(0)
  }
  if needle.length() > s.length() {
    return None
  }
  let mut idx = 0
  while idx <= s.length() - needle.length() {
    let mut is_match = true
    let mut j = 0
    while j < needle.length() {
      if s[idx + j] != needle[j] {
        is_match = false
        break
      }
      j = j + 1
    }
    if is_match {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn decoder_parse_int(s : String) -> Int? {
  let mut result = 0
  let mut idx = 0
  let len = s.length()
  if len == 0 { return None }
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

///|
/// Helper to split string and convert to array
fn split_to_array(s : String, sep : String) -> Array[String] {
  let result = []
  let mut start = 0
  let sep_len = sep.length()
  let mut idx = 0
  while idx <= s.length() - sep_len {
    let mut is_match = true
    let mut j = 0
    while j < sep_len {
      if s[idx + j] != sep[j] {
        is_match = false
        break
      }
      j = j + 1
    }
    if is_match {
      result.push(s.substring(start=start, end=idx))
      start = idx + sep_len
      idx = start
    } else {
      idx = idx + 1
    }
  }
  result.push(s.substring(start=start, end=s.length()))
  result
}
