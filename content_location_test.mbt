///|
fn init {
  // Test parse absolute URI
  let cl1 = ContentLocation::parse("https://example.com/path").unwrap()
  if cl1.uri().to_string() == "https://example.com/path" {
    println("content_location.mbt: Absolute URI parse OK")
  } else {
    println("content_location.mbt: Absolute URI parse FAILED")
  }

  // Test parse relative URI
  let cl2 = ContentLocation::parse("/assets/logo.png").unwrap()
  if cl2.uri().path() == "/assets/logo.png" {
    println("content_location.mbt: Relative URI parse OK")
  } else {
    println("content_location.mbt: Relative URI parse FAILED")
  }

  // Test to_string
  let cl3 = ContentLocation::parse("https://example.com/path").unwrap()
  let str3 = cl3.to_string()
  if str3 == "https://example.com/path" {
    println("content_location.mbt: to_string OK")
  } else {
    println("content_location.mbt: to_string FAILED: got " + str3)
  }

  // Test empty input
  let cl4 = ContentLocation::parse("")
  match cl4 {
    Ok(_) => println("content_location.mbt: Empty input FAILED")
    Err(Empty) => println("content_location.mbt: Empty input OK")
    Err(_) => println("content_location.mbt: Empty input wrong error")
  }

  // Test invalid URI
  let cl5 = ContentLocation::parse("http://[::1")
  match cl5 {
    Ok(_) => println("content_location.mbt: Invalid URI FAILED")
    Err(InvalidUri) => println("content_location.mbt: Invalid URI OK")
    Err(_) => println("content_location.mbt: Invalid URI wrong error")
  }

  // Test URI with query and fragment
  let cl6 = ContentLocation::parse("/path?query=value#fragment").unwrap()
  let uri6 = cl6.uri()
  if uri6.path() == "/path" &&
    uri6.query().unwrap() == "query=value" &&
    uri6.fragment().unwrap() == "fragment" {
    println("content_location.mbt: URI with query and fragment OK")
  } else {
    println("content_location.mbt: URI with query and fragment FAILED")
  }

  // Test URI accessor
  let cl7 = ContentLocation::parse("https://example.com:8080/path").unwrap()
  let uri7 = cl7.uri()
  if uri7.host().unwrap() == "example.com" && uri7.port().unwrap() == 8080 {
    println("content_location.mbt: URI accessor OK")
  } else {
    println("content_location.mbt: URI accessor FAILED")
  }
  println("content_location.mbt: All tests completed")
}
