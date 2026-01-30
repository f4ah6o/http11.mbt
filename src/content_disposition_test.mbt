///|
fn init {
  // Test parse inline
  let cd1 = ContentDisposition::parse("inline").unwrap()
  if cd1.disposition_type() == Inline && cd1.is_inline() {
    println("content_disposition.mbt: Parse inline OK")
  } else {
    println("content_disposition.mbt: Parse inline FAILED")
  }

  // Test parse attachment
  let cd2 = ContentDisposition::parse("attachment").unwrap()
  if cd2.disposition_type() == Attachment && cd2.is_attachment() {
    println("content_disposition.mbt: Parse attachment OK")
  } else {
    println("content_disposition.mbt: Parse attachment FAILED")
  }

  // Test parse attachment with filename
  let cd3 = ContentDisposition::parse("attachment; filename=\"example.txt\"").unwrap()
  if cd3.is_attachment() && cd3.filename().unwrap() == "example.txt" {
    println("content_disposition.mbt: Parse with filename OK")
  } else {
    println("content_disposition.mbt: Parse with filename FAILED")
  }

  // Test parse filename without quotes
  let cd4 = ContentDisposition::parse("attachment; filename=example.txt").unwrap()
  if cd4.filename().unwrap() == "example.txt" {
    println("content_disposition.mbt: Filename without quotes OK")
  } else {
    println("content_disposition.mbt: Filename without quotes FAILED")
  }

  // Test parse filename with escape
  let cd5 = ContentDisposition::parse(
    "attachment; filename=\"file\\\"name.txt\"",
  ).unwrap()
  if cd5.filename().unwrap() == "file\"name.txt" {
    println("content_disposition.mbt: Filename with escape OK")
  } else {
    println("content_disposition.mbt: Filename with escape FAILED")
  }

  // Test parse form-data
  let cd6 = ContentDisposition::parse("form-data; name=\"field1\"").unwrap()
  if cd6.is_form_data() && cd6.name().unwrap() == "field1" {
    println("content_disposition.mbt: Parse form-data OK")
  } else {
    println("content_disposition.mbt: Parse form-data FAILED")
  }

  // Test parse form-data with filename
  let cd7 = ContentDisposition::parse(
    "form-data; name=\"file\"; filename=\"image.png\"",
  ).unwrap()
  if cd7.is_form_data() &&
    cd7.name().unwrap() == "file" &&
    cd7.filename().unwrap() == "image.png" {
    println("content_disposition.mbt: Form-data with filename OK")
  } else {
    println("content_disposition.mbt: Form-data with filename FAILED")
  }

  // Test case insensitive
  let cd8 = ContentDisposition::parse("ATTACHMENT; FILENAME=\"test.txt\"").unwrap()
  if cd8.is_attachment() && cd8.filename().unwrap() == "test.txt" {
    println("content_disposition.mbt: Case insensitive OK")
  } else {
    println("content_disposition.mbt: Case insensitive FAILED")
  }

  // Test empty input
  let cd9 = ContentDisposition::parse("")
  match cd9 {
    Ok(_) => println("content_disposition.mbt: Empty input FAILED")
    Err(_) => println("content_disposition.mbt: Empty input OK")
  }

  // Test invalid type
  let cd10 = ContentDisposition::parse("unknown")
  match cd10 {
    Ok(_) => println("content_disposition.mbt: Invalid type FAILED")
    Err(_) => println("content_disposition.mbt: Invalid type OK")
  }

  // Test to_string
  let cd11 = ContentDisposition::new(Attachment).with_filename("test.txt")
  if cd11.to_string() == "attachment; filename=\"test.txt\"" {
    println("content_disposition.mbt: to_string OK")
  } else {
    println("content_disposition.mbt: to_string FAILED")
  }

  // Test builder
  let cd12 = ContentDisposition::new(Attachment).with_filename("example.txt")
  if cd12.is_attachment() && cd12.filename().unwrap() == "example.txt" {
    println("content_disposition.mbt: Builder OK")
  } else {
    println("content_disposition.mbt: Builder FAILED")
  }
  println("content_disposition.mbt: All tests completed")
}
