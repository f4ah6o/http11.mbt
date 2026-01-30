///|
/// Content-Location header parsing errors (RFC 9110 Section 8.6)
pub(all) enum ContentLocationError {
  Empty
  InvalidUri
} derive(Show, Eq)

///|
/// Content-Location header (RFC 9110 Section 8.6)
pub(all) struct ContentLocation {
  uri : Uri
} derive(Eq)

///|
pub fn ContentLocation::parse(
  input : String,
) -> Result[ContentLocation, ContentLocationError] {
  let s = clo_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let uri_result = Uri::parse(s)
  match uri_result {
    Ok(uri) => Ok({ uri, })
    Err(_) => Err(InvalidUri)
  }
}

///|
pub fn ContentLocation::uri(self : ContentLocation) -> Uri {
  self.uri
}

///|
pub fn ContentLocation::to_string(self : ContentLocation) -> String {
  self.uri.to_string()
}

///|
/// Helper functions
///

///|
fn clo_trim_string(s : String) -> String {
  str_trim_string(s)
}
