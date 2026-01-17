///|
fn main {
  let req = @lib.Request::new("GET", "/test")
  let encoded = @lib.encode_request(req)
  println("Encoded request: " + encoded.length().to_string() + " bytes")
}
