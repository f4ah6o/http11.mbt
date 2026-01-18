///|
fn init {
  // Test parse simple
  let ct1 = ContentType::parse("text/html").unwrap()
  if ct1.media_type() == "text" && ct1.subtype() == "html" && ct1.mime_type() == "text/html" {
    println("content_type.mbt: Simple parse OK")
  } else {
    println("content_type.mbt: Simple parse FAILED")
  }

  // Test parse with charset
  let ct2 = ContentType::parse("text/html; charset=utf-8").unwrap()
  if ct2.media_type() == "text" && ct2.subtype() == "html" && ct2.charset().unwrap() == "utf-8" {
    println("content_type.mbt: Parse with charset OK")
  } else {
    println("content_type.mbt: Parse with charset FAILED")
  }

  // Test parse with quoted charset
  let ct3 = ContentType::parse("text/html; charset=\"utf-8\"").unwrap()
  if ct3.charset().unwrap() == "utf-8" {
    println("content_type.mbt: Parse with quoted charset OK")
  } else {
    println("content_type.mbt: Parse with quoted charset FAILED")
  }

  // Test parse multipart
  let ct4 = ContentType::parse("multipart/form-data; boundary=----WebKitFormBoundary").unwrap()
  if ct4.is_form_data() && ct4.boundary().unwrap() == "----WebKitFormBoundary" {
    println("content_type.mbt: Parse multipart OK")
  } else {
    println("content_type.mbt: Parse multipart FAILED")
  }

  // Test case insensitivity
  let ct5 = ContentType::parse("TEXT/HTML; CHARSET=UTF-8").unwrap()
  if ct5.media_type() == "text" && ct5.subtype() == "html" && ct5.charset().unwrap() == "UTF-8" {
    println("content_type.mbt: Case insensitivity OK")
  } else {
    println("content_type.mbt: Case insensitivity FAILED")
  }

  // Test multiple parameters
  let ct6 = ContentType::parse("text/plain; charset=utf-8; boundary=something").unwrap()
  if ct6.charset().unwrap() == "utf-8" && ct6.boundary().unwrap() == "something" {
    println("content_type.mbt: Multiple parameters OK")
  } else {
    println("content_type.mbt: Multiple parameters FAILED")
  }

  // Test is_json
  let ct7 = ContentType::parse("application/json").unwrap()
  if ct7.is_json() {
    println("content_type.mbt: is_json OK")
  } else {
    println("content_type.mbt: is_json FAILED")
  }

  // Test is_form_urlencoded
  let ct8 = ContentType::parse("application/x-www-form-urlencoded").unwrap()
  if ct8.is_form_urlencoded() {
    println("content_type.mbt: is_form_urlencoded OK")
  } else {
    println("content_type.mbt: is_form_urlencoded FAILED")
  }

  // Test with spaces
  let ct9 = ContentType::parse("  text/html  ;  charset = utf-8  ").unwrap()
  if ct9.media_type() == "text" && ct9.subtype() == "html" {
    println("content_type.mbt: Parse with spaces OK")
  } else {
    println("content_type.mbt: Parse with spaces FAILED")
  }

  // Test quoted with escape
  let ct10 = ContentType::parse("text/plain; name=\"hello\\\"world\"").unwrap()
  if ct10.parameter("name").unwrap() == "hello\"world" {
    println("content_type.mbt: Quoted with escape OK")
  } else {
    println("content_type.mbt: Quoted with escape FAILED")
  }

  // Test empty input
  let ct11 = ContentType::parse("")
  match ct11 {
    Ok(_) => println("content_type.mbt: Empty input FAILED")
    Err(_) => println("content_type.mbt: Empty input OK")
  }

  // Test no subtype
  let ct12 = ContentType::parse("text")
  match ct12 {
    Ok(_) => println("content_type.mbt: No subtype FAILED")
    Err(_) => println("content_type.mbt: No subtype OK")
  }

  // Test empty subtype
  let ct13 = ContentType::parse("text/")
  match ct13 {
    Ok(_) => println("content_type.mbt: Empty subtype FAILED")
    Err(_) => println("content_type.mbt: Empty subtype OK")
  }

  // Test new and with_parameter
  let ct14 = ContentType::new("text", "html").with_parameter("charset", "utf-8")
  let str14 = ct14.to_string()
  if str14 == "text/html; charset=utf-8" {
    println("content_type.mbt: new and with_parameter OK")
  } else {
    println("content_type.mbt: new and with_parameter FAILED: got " + str14)
  }

  // Test is_text
  let ct15a = ContentType::parse("text/plain").unwrap()
  let ct15b = ContentType::parse("application/json").unwrap()
  if ct15a.is_text() && !ct15b.is_text() {
    println("content_type.mbt: is_text OK")
  } else {
    println("content_type.mbt: is_text FAILED")
  }

  // Test is_multipart
  let ct16a = ContentType::parse("multipart/form-data").unwrap()
  let ct16b = ContentType::parse("text/plain").unwrap()
  if ct16a.is_multipart() && !ct16b.is_multipart() {
    println("content_type.mbt: is_multipart OK")
  } else {
    println("content_type.mbt: is_multipart FAILED")
  }

  // Test to_string with quoted value
  let ct17 = ContentType::new("text", "plain").with_parameter("name", "hello world")
  let str17 = ct17.to_string()
  if str17 == "text/plain; name=\"hello world\"" {
    println("content_type.mbt: to_string with quoted value OK")
  } else {
    println("content_type.mbt: to_string with quoted value FAILED: got " + str17)
  }

  println("content_type.mbt: All tests completed")
}
