///|
fn init {
  // Test parse single encoding
  let ce1 = ContentEncoding::parse("gzip").unwrap()
  if ce1.has_gzip() && ce1.encodings().length() == 1 {
    println("content_encoding.mbt: Single encoding parse OK")
  } else {
    println("content_encoding.mbt: Single encoding parse FAILED")
  }

  // Test parse multiple encodings
  let ce2 = ContentEncoding::parse("gzip, deflate, identity").unwrap()
  if ce2.has_gzip() &&
    ce2.has_deflate() &&
    ce2.has_identity() &&
    ce2.encodings().length() == 3 {
    println("content_encoding.mbt: Multiple encodings parse OK")
  } else {
    println("content_encoding.mbt: Multiple encodings parse FAILED")
  }

  // Test parse br
  let ce3 = ContentEncoding::parse("br").unwrap()
  if ce3.has_br() && ce3.encodings().length() == 1 {
    println("content_encoding.mbt: BR encoding parse OK")
  } else {
    println("content_encoding.mbt: BR encoding parse FAILED")
  }

  // Test parse zstd
  let ce4 = ContentEncoding::parse("zstd").unwrap()
  if ce4.has_zstd() && ce4.encodings().length() == 1 {
    println("content_encoding.mbt: ZSTD encoding parse OK")
  } else {
    println("content_encoding.mbt: ZSTD encoding parse FAILED")
  }

  // Test case insensitivity
  let ce5 = ContentEncoding::parse("GZIP, Deflate").unwrap()
  if ce5.has_gzip() && ce5.has_deflate() {
    println("content_encoding.mbt: Case insensitivity OK")
  } else {
    println("content_encoding.mbt: Case insensitivity FAILED")
  }

  // Test to_string
  let ce6 = ContentEncoding::parse("gzip, deflate").unwrap()
  let str6 = ce6.to_string()
  if str6 == "gzip, deflate" {
    println("content_encoding.mbt: to_string OK")
  } else {
    println("content_encoding.mbt: to_string FAILED: got " + str6)
  }

  // Test trailing comma (should be OK)
  let ce7 = ContentEncoding::parse("gzip,")
  match ce7 {
    Ok(_) =>
      if ce7.unwrap().has_gzip() {
        println("content_encoding.mbt: Trailing comma OK")
      } else {
        println("content_encoding.mbt: Trailing comma FAILED")
      }
    Err(_) => println("content_encoding.mbt: Trailing comma FAILED")
  }

  // Test empty input
  let ce8 = ContentEncoding::parse("")
  match ce8 {
    Ok(_) => println("content_encoding.mbt: Empty input FAILED")
    Err(Empty) => println("content_encoding.mbt: Empty input OK")
    Err(_) => println("content_encoding.mbt: Empty input wrong error")
  }

  // Test invalid encoding with space
  let ce9 = ContentEncoding::parse("g zip")
  match ce9 {
    Ok(_) => println("content_encoding.mbt: Invalid encoding FAILED")
    Err(_) => println("content_encoding.mbt: Invalid encoding OK")
  }

  // Test unknown encoding (should be stored as Other)
  let ce10 = ContentEncoding::parse("unknown-coding").unwrap()
  let encs = ce10.encodings()
  match encs[0] {
    Other(s) =>
      if s == "unknown-coding" {
        println("content_encoding.mbt: Unknown encoding OK")
      } else {
        println("content_encoding.mbt: Unknown encoding FAILED")
      }
    _ => println("content_encoding.mbt: Unknown encoding FAILED")
  }
  println("content_encoding.mbt: All tests completed")
}
